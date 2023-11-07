# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acapi/version'

Gem::Specification.new do |spec|
  spec.name          = "acapi"
  spec.version       = Acapi::VERSION
  spec.authors       = ["Dan Thomas"]
  spec.email         = ["dan.thomas@dc.gov"]
  spec.summary       = %q{Enterprise communication onramp to Affordable Care Act API (ACApi)}
  spec.description   = %q{Publish and subscribe to ACApi cross-application events, services and logging.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "> 4.2.0"
  spec.add_dependency "bunny", ">= 1.7.0", "< 2.2"
  spec.add_dependency "sneakers"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rails", "> 4.2"
end
