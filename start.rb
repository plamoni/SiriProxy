#!/usr/bin/env ruby
KCODE='u' #setting KCODE to unicode for Ruby 1.8

require './plugins/thermostat/siriThermostat'
require './plugins/testproxy/testproxy'
require './plugins/eliza/eliza'
require './plugins/twitter/siriTweet'
require './tweakSiri'
require './siriProxy'

#Also try Eliza -- though it should really not be run "before" anything else.
#Also try Twitter -- must first configure keys in siriTweet.rb
PLUGINS = [TestProxy]

proxy = SiriProxy.new(PLUGINS)

#that's it. :-)
