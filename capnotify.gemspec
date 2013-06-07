# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capnotify/version'

Gem::Specification.new do |spec|
  spec.name          = "capnotify"
  spec.version       = Capnotify::VERSION
  spec.authors       = ["Spike Grobstein"]
  spec.email         = ["me@spike.cx"]
  spec.description   = %q{Extensible Capistrano notification system with helpers and sensible default values for common notification tasks.}
  spec.summary       = %q{Extensible Capistrano notification system.}
  spec.homepage      = "https://github.com/spikegrobstein/capnotify"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "awesome_print"

  spec.add_dependency "capistrano", "~> 2.14"
end
