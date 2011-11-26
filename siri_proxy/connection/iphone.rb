#####
  # This is the connection to the iPhone
#####
class SiriProxy::Connection::Iphone < SiriProxy::Connection
  def initialize
    puts "Create server for iPhone connection"
    super
    self.name = "iPhone"
  end

  def post_init
    super
    start_tls(:cert_chain_file  => "server.passless.crt",
              :private_key_file => "server.passless.key",
              :verify_peer      => false)
  end

  def ssl_handshake_completed
    super
    self.other_connection = EventMachine.connect('guzzoni.apple.com', 443, SiriProxy::Connection::Guzzoni)
    self.plugin_manager.guzzoni_conn = self.other_connection
    other_connection.other_connection = self #hehe
    other_connection.plugin_manager = plugin_manager
  end
  
  def received_object(object)
    object
    #plugin_manager.object_from_client(object, self)
  end
end
