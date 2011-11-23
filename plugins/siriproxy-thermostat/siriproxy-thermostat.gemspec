# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-thermostat"
  s.version     = "0.0.1" 
  s.authors     = ["plamoni"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Siri controller for RadioThermostat thermostat units}
  s.description = %q{This example plugin is more of a demonstration than anything else. If you happen to have a RadioThermostat thermostat, then you can use it if you like. But it's mostly for demonstration purposes. Check out the code and see what all you can do!}

  s.rubyforge_project = "siriproxy-thermostat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "json"
end
