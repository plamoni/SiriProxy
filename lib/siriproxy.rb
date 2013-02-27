require 'eventmachine'
require 'zlib'
require 'pp'

class String
  def to_hex(seperator=" ")
    bytes.to_a.map{|i| i.to_s(16).rjust(2, '0')}.join(seperator)
  end
end

class SiriProxy

  def initialize()
    # @todo shouldnt need this, make centralize logging instead
    $LOG_LEVEL = $APP_CONFIG.log_level.to_i
    EventMachine.run do
      begin
        listen_addr = $APP_CONFIG.listen || "0.0.0.0"
        puts "Starting SiriProxy on #{listen_addr}:#{$APP_CONFIG.port}.."
        EventMachine::start_server(listen_addr, $APP_CONFIG.port, SiriProxy::Connection::Iphone, $APP_CONFIG.upstream_dns) { |conn|
          puts "[Info - Guzzoni] Starting conneciton #{conn.inspect}" if $LOG_LEVEL < 1
          conn.plugin_manager = SiriProxy::PluginManager.new()
          conn.plugin_manager.iphone_conn = conn
        }
        puts "SiriProxy up and running."
      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "Cannot start the server on port #{$APP_CONFIG.port} - are you root, or have another process on this port already?"
        else
          raise
        end
      end

      EventMachine.set_effective_user($APP_CONFIG.user) if $APP_CONFIG.user
    end
  end
end
