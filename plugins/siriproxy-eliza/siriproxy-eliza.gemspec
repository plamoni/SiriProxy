# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-eliza"
  s.version     = "0.0.1" 
  s.authors     = ["plamoni"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Turns Siri into a psychotherapist}
  s.description = %q{Turns Siri into a psychotherapist}

  s.rubyforge_project = "siriproxy-eliza"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
