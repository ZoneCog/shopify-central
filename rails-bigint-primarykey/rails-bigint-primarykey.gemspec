# encoding: utf-8
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "bigint_primarykey/version"

Gem::Specification.new do |s|
  s.name        = "rails-bigint-primarykey"
  s.version     = BigintPrimarykey::VERSION
  s.authors     = ["Rafael Mendonça França"]
  s.email       = ["gems@shopify.com"]
  s.homepage    = "https://github.com/Shopify/rails-bigint-primarykey"
  s.summary     = 'Easily use 64-bit primary keys in Rails'
  s.description = 'Easily use 64-bit primary keys in Rails'
  s.license = 'MIT'

  s.files         = Dir["LICENSE", "Readme.md", "lib/**/*.rb"]
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency "activerecord", ">= 4.2"
  s.add_dependency "railties", ">= 4.2"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "pg"
end
