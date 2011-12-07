source :gemcutter

gemspec

# load plugins
require 'yaml'
require 'ostruct'

if !File.exists?(File.expand_path('~/.siriproxy/config.yml'))
  $stderr.puts "config.yml not found. Copy config.example.yml to config.yml, then modify it."
  exit 1
end

gem 'cora', :git => "git://github.com/chendo/cora.git"

config = OpenStruct.new(YAML.load_file(File.expand_path('~/.siriproxy/config.yml')))
if config.plugins
  config.plugins.each do |plugin|
    if plugin.is_a? String
      gem "siriproxy-#{plugin.downcase}"
    else
      gem "siriproxy-#{plugin['gem'] || plugin['name'].downcase}", :path => plugin['path'], :git => plugin['git'], :require => plugin['require']
    end
  end
end



if config.pluginManager && config.pluginManager.class
  if config.pluginManager.class.is_a? String
    gem "siriproxypm-#{config.pluginManager.class.downcase}"
  else
    gem "siriproxypm-#{config.pluginManager['class']['gem'] || config.pluginManager['class']['name'].downcase}",  
    :path => config.pluginManager['class']['path'], 
    :git => config.pluginManager['class']['git'],  
    :require => config.pluginManager['class']['require']
     
  end
end
