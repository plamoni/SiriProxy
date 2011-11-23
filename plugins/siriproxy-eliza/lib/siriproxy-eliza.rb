require 'siri_proxy'
require 'siriObjectGenerator'
require 'net/http'

class SiriProxy::Plugin::Eliza < SiriProxy::Plugin

  ####
  # This gets called every time an object is received from the Guzzoni server
  def object_from_guzzoni(object, connection) 
    object
  end
    
  ####
  # This gets called every time an object is received from an iPhone
  def object_from_client(object, connection)
    object
  end
  
  ####
  # When the server reports an "unkown command", this gets called. It's useful for implementing commands that aren't otherwise covered
  def unknown_command(object, connection, command)
    object
  end
  
  ####
  # This is called whenever the server recognizes speech. It's useful for overriding commands that Siri would otherwise recognize
  def speech_recognized(object, connection, phrase)
    plugin_manager.block_rest_of_session_from_server
    
    Thread.new {
      ###Contact eliza
      response =  Net::HTTP.post_form(URI.parse("http://www-ai.ijs.si/eliza-cgi-bin/eliza_script"),{'Entry1'=>phrase})
      
      addViews = SiriAddViews.new(false, false, "Reflection")
      addViews.make_root(connection.last_ref_id)

      puts response.body.split("</strong>\n").last.split("\n").first
      utterance = SiriAssistantUtteranceView.new(response.body.split("</strong>\n").last.split("\n").first)
      utterance.listenAfterSpeaking = true
      addViews.views << utterance
      
      connection.inject_object_to_output_stream(addViews.to_hash)
    }    

    return object
    
    ##connection.inject_object_to_output_stream()
    
    ##requestComplete = SiriRequestCompleted.new
    ##requestComplete.make_root(connection.last_ref_id)
    
    ##return requestComplete.to_hash
  end
end 
