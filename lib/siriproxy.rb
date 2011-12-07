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

    pm = nil    
    
    if $APP_CONFIG.pluginManager && $APP_CONFIG.pluginManager.class 
      if $APP_CONFIG.pluginManager.class.is_a?(String)
        class_name = $APP_CONFIG.pluginManager.class
        require_name = "siriproxypm-#{class_name.downcase}"
      else
        class_name = $APP_CONFIG.pluginManager["class"]["name"]
        require_name = $APP_CONFIG.pluginManager["class"]['require'] || "siriproxypm-#{class_name.downcase}" 
      end

      if require_name.length > 0 &&  class_name.length > 0 
        require(require_name) 
        if (klass = SiriProxy::PluginManager.const_get(class_name)).is_a?(Class)          
          pm = klass.new
        end
      end 
    else
      pm = SiriProxy::PluginManager.new
    end

    if pm == nil || !pm.kind_of?(SiriProxy::PluginManager)
      raise "Cannot instantiate plugin manager"
    end

    EventMachine.run do
      begin
        puts "Starting SiriProxy on port #{$APP_CONFIG.port}.."
        EventMachine::start_server('0.0.0.0', $APP_CONFIG.port, SiriProxy::Connection::Iphone) { |conn|
          $stderr.puts "start conn #{conn.inspect}"
          conn.plugin_manager = pm
          conn.plugin_manager.iphone_conn = conn
        }
      rescue RuntimeError => err
        if err.message == "no acceptor"
          raise "Cannot start the server on port #{$APP_CONFIG.port} - are you root, or have another process on this port already?"
        else
          raise
        end
      end
    end
  end
end
