# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "siriproxy/version"

Gem::Specification.new do |s|
  s.name        = "siriproxy"
  s.version     = SiriProxy::VERSION
  s.authors     = ["plamoni", "chendo", "netpro2k"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{A (tampering) proxy server for Apple's Siri}
  s.description = %q{Siri Proxy is a proxy server for Apple's Siri "assistant." The idea is to allow for the creation of custom handlers for different actions. This can allow developers to easily add functionality to Siri.}

  s.rubyforge_project = "siriproxy"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")

  s.add_runtime_dependency "CFPropertyList", "=2.1.2"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "uuidtools"
  s.add_development_dependency "rake"
end
