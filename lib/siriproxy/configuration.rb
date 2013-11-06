require 'yaml'
require 'ostruct'

puts "== Configuration =="

class SiriProxy
  def self.config=(configuration)
    @@config = configuration
  end
  
  def self.config
    @@config
  end
end

class SiriProxy::Configuration
  
  attr_reader :config

  def initialize
    @config_loaded = false
  end
  
  def config_loaded?
    !self.config.nil?
  end
  
  def config_path
    dir = File.expand_path(File.join('~', '.siriproxy'))
    
    unless File.exists?(dir)
      File.join('/', 'etc', 'siriproxy.d')
    else
      dir
    end
  end
  
  def config_file
    File.join(config_path, 'config.yml')  
  end
  
  def certificate_file
    File.join(config_path, 'server.passless.crt')
  end    

  def certificate_key_file
    File.join(config_path, 'server.passless.key')
  end    
  
  def load_configuration
    @config = OpenStruct.new(YAML.load_file(File.expand_path(config_file))) 
  end
  
  def method_missing(selector, *args)  
    load_configuration unless config_loaded?
    @config.__send__(selector, *args)
  end
     
end


# Prepare for lazy-loaded config here
SiriProxy.config = SiriProxy::Configuration.new
