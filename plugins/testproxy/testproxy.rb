require 'tweakSiri'
require 'siriObjectGenerator'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "text siri proxy" and responds
# with a message about the proxy being up and running. This is good base code for other plugins.
# 
# Remember to add other plugins to the "start.rb" file if you create them!
######


class TestProxy < SiriPlugin

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
		if(command.match(/test siri proxy/i))
			self.plugin_manager.block_rest_of_session_from_server
			
			return generate_siri_utterance(connection.lastRefId, "Siri Proxy is up and running!")
		end	
		
		
		object
	end
	
	####
	# This is called whenever the server recognizes speech. It's useful for overriding commands that Siri would otherwise recognize
	def speech_recognized(object, connection, phrase)
		if(phrase.match(/siri proxy map/i))
			self.plugin_manager.block_rest_of_session_from_server
			
			connection.inject_object_to_output_stream(object)
			
			addViews = SiriAddViews.new
			addViews.make_root(connection.lastRefId)
			mapItemSnippet = SiriMapItemSnippet.new
			mapItemSnippet.items << SiriMapItem.new
			utterance = SiriAssistantUtteranceView.new("Testing map injection!")
			addViews.views << utterance
			addViews.views << mapItemSnippet
			
			connection.inject_object_to_output_stream(addViews.to_hash)
			
			requestComplete = SiriRequestCompleted.new
			requestComplete.make_root(connection.lastRefId)
			
			return requestComplete.to_hash
		end
		
		object
	end
	
end 