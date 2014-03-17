require 'rubydns'

class SiriProxy::Dns
  attr_accessor :interfaces, :upstream, :thread

  def initialize
    @interfaces = [
      [:tcp, "0.0.0.0", 53],
      [:udp, "0.0.0.0", 53]
    ]
  
    servers = []

    $APP_CONFIG.upstream_dns.each { |dns_addr|
      servers << [:udp, dns_addr, 53]
      servers << [:tcp, dns_addr, 53]
    }

    @upstream = RubyDNS::Resolver.new(servers)
  end

  def start(log_level=Logger::WARN)
    @thread = Thread.new {
      begin
        self.run(log_level)
        $SP_DNS_STARTED = true
      rescue RuntimeError => e
        if e.message.match /^no acceptor/
          puts "[Error - Server] Either you're not root or tcp/udp port 53 is in use. DNS server is disabled"
          $SP_DNS_STARTED = true #Yeah, it didn't start, but we don't want to sit around and wait for it.
        else
          puts "[Error - Server] DNS Error: #{e.message}"
          puts "[Error - Server] DNS Server has crashed. Terminating SiriProxy"
          exit 1
        end
      rescue Exception => e
        puts "[Error - Server] DNS Error: #{e.message}"
        puts "[Error - Server] DNS Server has crashed. Terminating SiriProxy"
        exit 1
      end
    }
  end

  def stop
    Thread.kill(@thread)
  end

  def run(log_level=Logger::WARN,server_ip=$APP_CONFIG.server_ip)
    if server_ip
      upstream = @upstream
        
      # Start the RubyDNS server
      RubyDNS::run_server(:listen => @interfaces) do
        @logger.level = log_level

        match(/guzzoni.apple.com/, Resolv::DNS::Resource::IN::A) do |transaction|
          transaction.respond!(server_ip)
        end

        # Default DNS handler
        otherwise do |transaction|
          transaction.passthrough!(upstream)
        end
      end

      puts "[Info - Server] DNS Server started, tainting 'guzzoni.apple.com' with #{server_ip}"
    end
  end
end
