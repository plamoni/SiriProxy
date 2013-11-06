source 'https://rubygems.org'

gemspec

# load plugins
require 'siriproxy/configuration'

gem 'cora', '0.0.4'

                                                                      
if SiriProxy.config.plugins
  puts "[Info - Configuration] Loading plugins -- If any fail to load, run `siriproxy bundle` (not `bundle install`) to resolve."
  SiriProxy.config.plugins.each do |plugin|
    if plugin.is_a? String
      gem "siriproxy-#{plugin.downcase}"
    else
  	  gem "siriproxy-#{plugin['gem'] || plugin['name'].downcase}", :path => plugin['path'], :git => plugin['git'], :branch => plugin['branch'], :require => plugin['require']
    end
  end
end
