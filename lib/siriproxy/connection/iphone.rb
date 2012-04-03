require 'resolv'

#####
  # This is the connection to the iPhone
#####
class SiriProxy::Connection::Iphone < SiriProxy::Connection
  def initialize upstream_dns
    puts "Create server for iPhone connection"
    super()
    self.name = "iPhone"
    @upstream_dns = upstream_dns
  end

  def post_init
    super
    start_tls(:cert_chain_file  => File.expand_path("~/.siriproxy/server.passless.crt"),
              :private_key_file => File.expand_path("~/.siriproxy/server.passless.key"),
              :verify_peer      => false)
  end

  # Resolves guzzoni.apple.com using the Google DNS servers.  This allows the
  # machine running siriproxy to use the DNS server returning fake records for
  # guzzoni.apple.com.

  def resolve_guzzoni
    addresses = Resolv::DNS.open(nameserver: @upstream_dns) do |dns|
      res = dns.getresources('guzzoni.apple.com', Resolv::DNS::Resource::IN::A)
    
      res.map { |r| r.address }
    end
    
    addresses.map do |address|
      address.address.unpack('C*').join('.')
    end.sample
  end

  def ssl_handshake_completed
    super
    self.other_connection = EventMachine.connect(resolve_guzzoni, 443, SiriProxy::Connection::Guzzoni)
    self.plugin_manager.guzzoni_conn = self.other_connection
    other_connection.other_connection = self #hehe
    other_connection.plugin_manager = plugin_manager
  end
  
  def received_object(object)
    return plugin_manager.process_filters(object, :from_iphone)

    #plugin_manager.object_from_client(object, self)
  end
end
