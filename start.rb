#!/usr/bin/env ruby
$LOAD_PATH << File.dirname(__FILE__)
$KCODE='u' #setting KCODE to unicode for Ruby 1.8

require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'yaml'
require 'ostruct'

require 'siri_proxy'
require 'siri_proxy/connection'
require 'siri_proxy/connection/iphone'
require 'siri_proxy/connection/guzzoni'

require 'siri_proxy/plugin'
require 'siri_proxy/plugin_manager'

APP_CONFIG = OpenStruct.new(YAML.load_file('config.yml'))
LOG_LEVEL = APP_CONFIG.log_level.to_i
proxy = SiriProxy.new()

#that's it. :-)
