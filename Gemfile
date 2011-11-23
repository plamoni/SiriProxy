source :gemcutter

gem 'CFPropertyList'
gem 'eventmachine'
gem 'uuidtools'

# load plugins
require 'yaml'
require 'ostruct'
config = OpenStruct.new(YAML.load_file('config.yaml'))
if config.plugins
  config.plugins.each do |plugin|
    if plugin.is_a? String
      gem "siriproxy-#{plugin.downcase}"
    else
      gem "siriproxy-#{plugin['name'].downcase}", :path => plugin['path'], :git => plugin['git'], :require => plugin['require']
    end
  end
end
