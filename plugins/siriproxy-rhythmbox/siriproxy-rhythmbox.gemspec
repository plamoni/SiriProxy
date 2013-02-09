# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-rhythmbox"
  s.version     = "0.0.1"
  s.authors     = ["Javier Martinez Canillas"]
  s.email       = ["javier@dowhile0.org"]
  s.homepage    = ""
  s.summary     = %q{An simple Siri Proxy Plugin for Rhythmbox}
  s.description = %q{A simple Siri Proxy plugin that controls the Rhythmbox music player using D-Bus. }

  s.rubyforge_project = "siriproxy-rhythmbox"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_runtime_dependency('ruby-dbus', '0.9.0')
end
