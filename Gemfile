source 'https://rubygems.org'

gemspec

# load plugins
require 'yaml'
require 'ostruct'
config_file = File.expand_path(File.join('~', '.siriproxy', 'config.yml'));

unless File.exists?(config_file)
  default_config = config_file
  config_file = File.expand_path(File.join(File.dirname(__FILE__), 'config.example.yml'))
  puts "[Notice - Configuration] ==================== Important Configuration Notice =========================="
  puts "[Notice - Configuration] '#{default_config}' not found. Using '#{config_file}'"
  puts "[Notice - Configuration] "
  puts "[Notice - Configuration] Remove this message by copying '#{config_file}' into '~/.siriproxy/'"
  puts "[Notice - Configuration] =============================================================================="
end

gem 'cora', '0.0.4'

config = OpenStruct.new(YAML.load_file(File.expand_path(config_file)))
if config.plugins
  puts "[Info - Configuration] Loading plugins -- If any fail to load, run `siriproxy bundle` (not `bundle install`) to resolve."
  config.plugins.each do |plugin|
    if plugin.is_a? String
      gem "siriproxy-#{plugin.downcase}"
    else
  	  gem "siriproxy-#{plugin['gem'] || plugin['name'].downcase}", :path => plugin['path'], :git => plugin['git'], :branch => plugin['branch'], :require => plugin['require']
    end
  end
end
