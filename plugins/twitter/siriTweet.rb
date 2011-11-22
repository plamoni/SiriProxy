require 'rubygems'
require 'tweakSiri'
require 'siriObjectGenerator'
require 'twitter'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "text siri proxy" and responds
# with a message about the proxy being up and running. This is good base code for other plugins.
# 
# Remember to add other plugins to the "start.rb" file if you create them!
######


class SiriTweet < SiriPlugin

	def initialize()
		@state = :DEFAULT_STATE 
		Twitter.configure do |config|
		  config.consumer_key = "YOUR KEY" 
		  config.consumer_secret = "YOUR SECRET"
		  config.oauth_token = "YOUR TOKEN" 
		  config.oauth_token_secret = "YOUR TOKEN SECRET"
		end 

		@twitterClient= Twitter::Client.new

# Post a status update
		
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
			connection.otherConnection.inject_object_to_output_stream self.speech_recognized object, connection, object['properties']['utterance']
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
		confirmationOptions = SiriConfirmationOptions.new(
			[SiriSendCommands.new([SiriConfirmSnippetCommand.new(),SiriStartRequest.new("yes",false,true)])],
			[SiriSendCommands.new([SiriCancelSnippetCommand.new(),SiriStartRequest.new("no",false,true)])],
			[SiriSendCommands.new([SiriCancelSnippetCommand.new(),SiriStartRequest.new("no",false,true)])],
			[SiriSendCommands.new([SiriConfirmSnippetCommand.new(),SiriStartRequest.new("yes",false,true)])]
		)

		object.views << SiriAssistantUtteranceView.new("Here is your tweet:", "Here is your tweet. Ready to send it?", "Misc#ident", true)
		object.views << SiriAnswerSnippet.new([answer], confirmationOptions)

		object.to_hash
	end
	
	####
	# This is called whenever the server recognizes speech. It's useful for overriding commands that Siri would otherwise recognize
	def speech_recognized(object, connection, phrase)
		if @state == :DEFAULT_STATE 
			if phrase.match(/^tweet (.+)/i)
				self.plugin_manager.block_rest_of_session_from_server
				@state = :CONFIRM_STATE
				@tweetText = $1
				return self.generate_tweet_response(connection.lastRefId, $1);
			end
		elsif @state == :CONFIRM_STATE
			if phrase.match(/yes/i)
				self.plugin_manager.block_rest_of_session_from_server
				@state = :DEFAULT_STATE
				@twitterClient.update(@tweetText) # this should probably be done in a seperate thread
				return generate_siri_utterance(connection.lastRefId, "Ok it has been posted to Twitter.")
			end
			if phrase.match(/no/i)
				self.plugin_manager.block_rest_of_session_from_server
				@state = :DEFAULT_STATE
				return generate_siri_utterance(connection.lastRefId, "Ok I won't send it.")
			end

			self.plugin_manager.block_rest_of_session_from_server
			return generate_siri_utterance(connection.lastRefId, "Do you want me to send it?", "I'm sorry. I don't understand. Do you want me to send it? Say yes or no.", true)
		end

		object
	end
	
end 
