require 'siri_proxy'
require 'siriObjectGenerator'
require 'twitter'

class SiriProxy::Plugin::Twitter < SiriProxy::Plugin

  VERSION = "0.0.1"

  def initialize(pluginConfig)
    @state = :DEFAULT_STATE 
    ::Twitter.configure do |config|
      config.consumer_key = pluginConfig['consumer_key'] 
      config.consumer_secret = pluginConfig['consumer_secret']
      config.oauth_token = pluginConfig['oauth_token'] 
      config.oauth_token_secret = pluginConfig['oauth_token_secret']
    end 

    @twitterClient = ::Twitter::Client.new
  end

  ####
  # This gets called every time an object is received from the Guzzoni server
  def object_from_guzzoni(object, connection) 
    object
  end
    
  ####
  # This gets called every time an object is received from an iPhone
  def object_from_client(object, connection)
    # They clicked cancel/send buttons instead of speaking
    if @state == :CONFIRM_STATE && object['class'] == "StartRequest" && object['properties']['proxyOnly']
      connection.other_connection.inject_object_to_output_stream self.speech_recognized object, connection, object['properties']['utterance']
    end
    object
  end
  
  
  ####
  # When the server reports an "unkown command", this gets called. It's useful for implementing commands that aren't otherwise covered
  def unknown_command(object, connection, command)
    object
  end

  def generate_tweet_response(refId, text="")
    object = SiriAddViews.new
    object.make_root(refId)

    answer = SiriAnswer.new("Tweet", [
      SiriAnswerLine.new('logo','http://cl.ly/1l040J1A392n0M1n1g35/content'), # this just makes things looks nice, but is obviously specific to my username
      SiriAnswerLine.new(text)
    ])
    confirmation_options = SiriConfirmationOptions.new(
      [SiriSendCommands.new([SiriConfirmSnippetCommand.new(),SiriStartRequest.new("yes",false,true)])],
      [SiriSendCommands.new([SiriCancelSnippetCommand.new(),SiriStartRequest.new("no",false,true)])],
      [SiriSendCommands.new([SiriCancelSnippetCommand.new(),SiriStartRequest.new("no",false,true)])],
      [SiriSendCommands.new([SiriConfirmSnippetCommand.new(),SiriStartRequest.new("yes",false,true)])]
    )

    object.views << SiriAssistantUtteranceView.new("Here is your tweet:", "Here is your tweet. Ready to send it?", "Misc#ident", true)
    object.views << SiriAnswerSnippet.new([answer], confirmation_options)

    object.to_hash
  end
  
  ####
  # This is called whenever the server recognizes speech. It's useful for overriding commands that Siri would otherwise recognize
  def speech_recognized(object, connection, phrase)
    if @state == :DEFAULT_STATE 
      if phrase.match(/^tweet (.+)/i)
        plugin_manager.block_rest_of_session_from_server
        @state = :CONFIRM_STATE
        @tweetText = $1
        return generate_tweet_response(connection.last_ref_id, $1);
      end
    elsif @state == :CONFIRM_STATE
      if phrase.match(/yes/i)
        plugin_manager.block_rest_of_session_from_server
        @state = :DEFAULT_STATE
        @twitterClient.update(@tweetText) # this should probably be done in a seperate thread
        return generate_siri_utterance(connection.last_ref_id, "Ok it has been posted to Twitter.")
      end
      if phrase.match(/no/i)
        plugin_manager.block_rest_of_session_from_server
        @state = :DEFAULT_STATE
        return generate_siri_utterance(connection.last_ref_id, "Ok I won't send it.")
      end

      plugin_manager.block_rest_of_session_from_server
      return generate_siri_utterance(connection.last_ref_id, "Do you want me to send it?", "I'm sorry. I don't understand. Do you want me to send it? Say yes or no.", true)
    end

    object
  end
  
end 
