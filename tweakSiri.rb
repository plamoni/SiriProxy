require 'pp'

class SiriPluginManager
	attr_accessor :plugins

	def initialize(pluginClasses=[])
		self.plugins = []
		
		pluginClasses.each { |pluginClass|
			plugin = pluginClass.new
			plugin.plugin_manager = self
			self.plugins << plugin
		}
	
		@blockNextObjectsFromServer = 0
		@blockNextObjectsFromClient = 0
		@blockRestOfSessionFromServer = false
	end
	
	def object_from_guzzoni(object, connection) 
		if(@blockRestOfSessionFromServer)
			if(connection.lastRefId == object["refId"])
				puts "[Info - Dropping Object from Guzzoni] #{object["class"]}"
				return nil
			else
				@blockRestOfSessionFromServer = false
			end
		end
		
		if(@blockNextObjectsFromServer > 0)
			puts "[Info - Dropping Object from Guzzoni] #{object["class"]}"
			@blockNextObjectsFromServer -= 1
			return nil
		end
		
		plugins.each { |plugin|
			object = plugin.object_from_guzzoni(object, connection)
		}
		
		object
	end
	
	def object_from_client(object, connection)
		if(@blockNextObjectsFromClient > 0)
			puts "[Info - Dropping Object from iPhone] #{object["class"]}"
			@blockNextObjectsFromClient -= 1
			return nil
		end
		
		##Often this indicates a bug in OUR code. So let's not send it to Apple. :-)
		if(object["class"] == "CommandIgnored")
			pp object
			return nil
		end
		
		plugins.each { |plugin|
			object = plugin.object_from_client(object, connection)
		}
		
		object
	end
	
	def unknown_command(object, connection, command)
		puts "[UnknownCommand] #{command}"

		plugins.each { |plugin|
			object = plugin.unknown_command(object, connection, command)
		}

		object
	end
	
	def speech_recognized(object, connection, phrase)
		puts "[Recognized Speech] #{phrase}"
		
		plugins.each { |plugin|
			object = plugin.speech_recognized(object, connection, phrase)
		}
		
		object
	end
	
	
	def block_next_objects_from_server(count=1)
		@blockNextObjectsFromServer += count		
	end
	
	def block_next_objects_from_client(count=1)
		@blockNextObjectsFromClient += count		
	end
	
	#Blocks everything from server until a new refId is seen
	def block_rest_of_session_from_server
		@blockRestOfSessionFromServer = true
	end
end

class SiriPlugin
	attr_accessor :plugin_manager

	def object_from_guzzoni(object, connection) 
		
		object
	end
	
	
	#Don't forget to return the object!
	def object_from_client(object, connection)
		
		object
	end
	
	
	def unknown_command(object, connection, command)
		
		object
	end
	
	def speech_recognized(object, connection, phrase)
		
		object
	end
	
end 