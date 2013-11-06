require 'yaml'
require 'ostruct'

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

  VALID_PATHS = [
    File.expand_path(File.join('~', '.siriproxy')),
    File.join('/', 'etc', 'siriproxy.d')
  ]




  def initialize
    @config_loaded = false
  end
  
  def config_loaded?
    !self.config.nil?
  end
  
  def config_path
    @config_path = find_config_path if @config_path.nil?
    @config_path
  end
  
  def find_config_path
    # Check all possible configuration paths, higher priority first,
    # returning the first valid path found

    SiriProxy::Configuration::VALID_PATHS.each do |path|
      if File.exists?(path)
        puts "Using configuration in #{path}"
        return path 
      end
    end
    
    puts "Configuration Error: No valid configuration could be found. Please run '#{$0} genconfig' to create one"
    
    raise "No config"
    
    exit 1
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
  
  class << self
    
    def create_default
      require 'readline'
      require 'fileutils'
      
      puts "Generating default SiriProxy configuration\n"
      path = get_preferred_path

      # Create a directory for the configuration and certificates to go in
      puts "=> Creating #{path}"
      FileUtils.mkdir(path)
      
      puts "=> Creating default config.yml"
      default_config = File.join(File.dirname(__FILE__), '..', '..', 'config.example.yml')
      FileUtils.cp(default_config, File.join(path, 'config.yml'))
      
    end
    
    def get_preferred_path
      puts "New configuration location:"

      VALID_PATHS.each_with_index do |path, i|
        puts "#{i+1}: #{path}"
      end
      
      choice = nil
      loop do
        choice = Readline.readline("Location [1]: ")
        break if choice=~/\d{1,}/ && choice.to_i > 0 && choice.to_i <= VALID_PATHS.length
        
        puts "Invalid choice. Please enter a choice between 1 and #{VALID_PATHS.length}"
      end

      return VALID_PATHS[choice.to_i-1]
    end
    
    
  end

end


# Prepare for lazy-loaded config here
SiriProxy.config = SiriProxy::Configuration.new
