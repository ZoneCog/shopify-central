require 'simplecov'
SimpleCov.start
require 'rspec'

require File.expand_path('../../lib/chef_git.rb', __FILE__)

FIXTURE_PATH = File.expand_path("fixtures/", File.dirname(__FILE__))
Chef::Config[:data_bag_path] = File.join(FIXTURE_PATH, 'data_bags')

def fixture(name)
  path = File.join(FIXTURE_PATH, name)
  File.read(path)
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
