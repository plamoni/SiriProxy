#!/usr/bin/env ruby
$LOAD_PATH << File.dirname(__FILE__)
$KCODE='u' #setting KCODE to unicode for Ruby 1.8

require 'tweakSiri'
require 'siriProxy'

Dir[File.dirname(__FILE__) + "/plugins-active/*/*.rb"].each {|plugin| require plugin}
proxy = SiriProxy.new
