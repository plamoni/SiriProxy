#!/usr/bin/env ruby
require 'plugins/thermostat/sirithermostat'
require 'plugins/testproxy/testproxy'
require 'tweaksiri'
require 'siriproxy'

PLUGINS = [TextProxy]

proxy = SiriProxy.new(PLUGINS)

#that's it. :-)