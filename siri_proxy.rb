require 'eventmachine'
require 'zlib'
require 'pp'
# require 'tweakSiri'
require 'interpretSiri'

LOG_LEVEL = 1

class String
	def to_hex(seperator=" ")
		self.bytes.to_a.map{|i| i.to_s(16).rjust(2, '0')}.join(seperator)
	end
end

class SiriProxy
	def initialize(pluginClasses=[])
		EventMachine.run do
		  begin
				puts "Starting SiriProxy on port 443.."
  			EventMachine::start_server('0.0.0.0', 4443, SiriProxy::Connection::Iphone) { |conn|
  				conn.pluginManager = SiriProxy::SiriPluginManager.new(
  					pluginClasses
  				)
  			}
  		rescue RuntimeError => err
  		  if err.message == "no acceptor"
  		    raise "Cannot start the server on port 443 - are you root?"
  		  else
  		    raise
  		  end
  		end
		end
	end
end

Interpret = InterpretSiri.new

