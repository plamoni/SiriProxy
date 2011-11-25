# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "siriproxy/version"

Gem::Specification.new do |s|
  s.name        = "siriproxy"
  s.version     = Siriproxy::VERSION
  s.authors     = ["plamoni", "chendo", "netpro2k"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "siriproxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.executables << 'siriproxy'

  s.add_runtime_dependency "CFPropertyList"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "uuidtools"
  s.add_development_dependency "rake"
end
