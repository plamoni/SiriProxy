class SiriProxy::SiriPlugin
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
