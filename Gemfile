source :gemcutter

# load plugins
require 'yaml'
require 'ostruct'

if !File.exists?('config.yml')
  $stderr.puts "config.yml not found. Copy config.example.yml to config.yml, then modify it."
  exit 1
end

# @todo this should move to gemspec once it is published
# keeping here for now since I dont think you can add git
# dependanceis directly to gemspecs
gem 'cora', :git => "git://github.com/chendo/cora.git"

config = OpenStruct.new(YAML.load_file('config.yml'))
if config.plugins
  config.plugins.each do |plugin|
    if plugin.is_a? String
      gem "siriproxy-#{plugin.downcase}"
    else
      gem "siriproxy-#{plugin['gem'] || plugin['name'].downcase}", :path => plugin['path'], :git => plugin['git'], :require => plugin['require']
    end
  end
end
