require 'eventmachine'
require 'zlib'
require 'pp'
# require 'tweakSiri'
require 'interpretSiri'

LOG_LEVEL = 6

class String
  def to_hex(seperator=" ")
    bytes.to_a.map{|i| i.to_s(16).rjust(2, '0')}.join(seperator)
  end
end

class SiriProxy
  PORT = 443
  
  def initialize(pluginClasses=[])
    EventMachine.run do
      begin
        puts "Starting SiriProxy on port #{PORT}.."
        EventMachine::start_server('0.0.0.0', PORT, SiriProxy::Connection::Iphone) { |conn|
          $stderr.puts "start conn #{conn.inspect}"
          conn.plugin_manager = SiriProxy::PluginManager.new(pluginClasses)
        }
      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "Cannot start the server on port #{PORT} - are you root, or have another process on this port already?"
        else
          raise
        end
      end
    end
  end
end

Interpret = InterpretSiri.new

