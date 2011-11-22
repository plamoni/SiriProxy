#####
# This is the connection to the Guzzoni (the Siri server backend)
#####
class SiriProxy::Connection::Guzzoni < SiriProxy::Connection
	def initialize
		super
		self.name = "Guzzoni"
	end

	def connection_completed
		super
		start_tls(:verify_peer => false)
	end
	
	def received_object(object)		
		self.pluginManager.object_from_guzzoni(object, self)
	end
end