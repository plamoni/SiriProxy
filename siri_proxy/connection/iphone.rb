#####
# This is the connection to the iPhone
#####
class SiriProxy::Connection::Iphone < SiriProxy::Connection
	def initialize
		super
		self.name = "iPhone"
	end

	def post_init
		super
		start_tls(:cert_chain_file => "server.passless.crt",
				 :private_key_file => "server.passless.key",
				 	  :verify_peer => false)
	end

	def ssl_handshake_completed
		super
		self.otherConnection = EventMachine.connect('guzzoni.apple.com', 443, SiriProxy::Connection::Guzzoni)
		self.otherConnection.otherConnection = self #hehe
		self.otherConnection.pluginManager = self.pluginManager
	end
	
	def received_object(object)
		self.pluginManager.object_from_client(object, self)
	end
end