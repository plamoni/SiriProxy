# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-twitter"
  s.version     = "0.0.1"
  s.authors     = ["netpro2k"]
  s.email       = ["netpro2k@gmail.com"]
  s.homepage    = "http://netpro2k.com"
  s.summary     = %q{Teach Siri how to tweet}
  s.description = %q{This is a very simple plugin for posting to twitter from siri}

  s.rubyforge_project = "siriproxy-twitter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here
  s.add_runtime_dependency "twitter"
end
