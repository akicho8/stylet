$:.push File.expand_path("../lib", __FILE__)
require "stylet/version"

Gem::Specification.new do |s|
  s.name          = "stylet"
  s.version       = Stylet::VERSION
  s.summary       = "Simple SDL library"
  s.description   = "Simple SDL library description"
  s.author        = "akicho8"
  s.homepage      = "http://github.com/akicho8/stylet"
  s.email         = "akicho8@gmail.com"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {s,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rsdl"
  s.add_dependency "rubysdl"
  s.add_dependency "activesupport"
  s.add_dependency "activemodel"
  s.add_dependency "i18n"
  s.add_dependency "rake"
  s.add_dependency "memory_record"
  s.add_dependency "stylet_support"
  s.add_dependency "rgb"

  s.add_development_dependency "rcodetools"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "rspec"
end
