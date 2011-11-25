require 'eventmachine'
require 'zlib'
require 'pp'
# require 'tweakSiri'
require 'interpret_siri'

class String
  def to_hex(seperator=" ")
    bytes.to_a.map{|i| i.to_s(16).rjust(2, '0')}.join(seperator)
  end
end

class SiriProxy
  
  def initialize()
    EventMachine.run do
      begin
        puts "Starting SiriProxy on port #{APP_CONFIG.port}.."
        EventMachine::start_server('0.0.0.0', APP_CONFIG.port, SiriProxy::Connection::Iphone) { |conn|
          $stderr.puts "start conn #{conn.inspect}"
          conn.plugin_manager = SiriProxy::PluginManager.new()
          conn.plugin_manager.iphone_conn = conn
        }
      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "Cannot start the server on port #{APP_CONFIG.port} - are you root, or have another process on this port already?"
        else
          raise
        end
      end
    end
  end
end

Interpret = InterpretSiri.new

