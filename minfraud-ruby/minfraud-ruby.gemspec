# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minfraud/version'

Gem::Specification.new do |spec|
  spec.name          = "minfraud-ruby"
  spec.version       = Minfraud::VERSION
  spec.authors       = ["Robbie Pitts"]
  spec.email         = ["robbie@sweatypitts.com"]
  spec.summary       = %q{Ruby interface to the MaxMind minFraud API service.}
  spec.license       = "GNU GPL"
  spec.homepage      = "https://github.com/Shopify/minfraud-ruby"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "faraday", "~> 1.0"
  spec.add_runtime_dependency "faraday_middleware", "~> 1.0"
  spec.add_runtime_dependency "net-http-persistent", "~> 4.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "bigdecimal"
end
