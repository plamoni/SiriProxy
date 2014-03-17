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
      if Process.uid == 0 && !$APP_CONFIG.user
        puts "[Notice - Server] ======================= WARNING: Running as root ============================="
        puts "[Notice - Server] You should use -l or the config.yml to specify and non-root user to run under"
        puts "[Notice - Server] Running the server as root is dangerous."
        puts "[Notice - Server] =============================================================================="
      end

      begin
        listen_addr = $APP_CONFIG.listen || "0.0.0.0"
        puts "[Info - Server] Starting SiriProxy on #{listen_addr}:#{$APP_CONFIG.port}..."
        EventMachine::start_server(listen_addr, $APP_CONFIG.port, SiriProxy::Connection::Iphone, $APP_CONFIG.upstream_dns) { |conn|
          puts "[Info - Guzzoni] Starting conneciton #{conn.inspect}" if $LOG_LEVEL < 1
          conn.plugin_manager = SiriProxy::PluginManager.new()
          conn.plugin_manager.iphone_conn = conn
        }
      
        retries = 0
        while $APP_CONFIG.server_ip && !$SP_DNS_STARTED && retries <= 5
          puts "[Info - Server] DNS server is not running yet, waiting #{2**retries} second#{'s' if retries > 1}..."
          sleep 2**retries
          retries += 1
        end

        if retries > 5
          puts "[Error - Server] DNS server did not start up."
          exit 1
        end

        EventMachine.set_effective_user($APP_CONFIG.user) if $APP_CONFIG.user
        puts "[Info - Server] SiriProxy up and running."

      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "[Error - Server] Cannot start the server on port #{$APP_CONFIG.port} - are you root, or have another process on this port already?"
        else
          raise
        end
      end
    end
  end
end
