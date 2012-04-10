source :gemcutter

gemspec

gem 'cora', :git => "git://github.com/chendo/cora.git"

if !File.exists?(File.expand_path('~/.siriproxy/config.yml'))
  abort "config.yml not found. Copy config.example.yml to config.yml, then modify it."
end

require 'yaml'

config_yml = File.expand_path('~/.siriproxy/config.yml')
config = YAML.load_file(config_yml)

if plugins = config['plugins']
  plugins.each do |plugin|
    if plugin.is_a? String
      gem "siriproxy-#{plugin.downcase}"
    else
      name = plugin['gem'] || plugin['name'].downcase

      gem("siriproxy-#{name}",
          :path => plugin['path'],
          :git => plugin['git'],
          :branch => plugin['branch'],
          :require => plugin['require'])
    end
  end
end
