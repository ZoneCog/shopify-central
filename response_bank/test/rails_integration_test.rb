# frozen_string_literal: true
require File.dirname(__FILE__) + "/test_helper"

module Dummy
  class Application < ::Rails::Application
    config.eager_load = false
  end
end

module ActiveRecord
  class Base
    ActiveSupport.run_load_hooks(:active_record, self)
  end
end

Dummy::Application.initialize!

class RailsIntegrationTest < Minitest::Test
  def test_middleware_is_included
    assert_includes(Dummy::Application.middleware, ResponseBank::Middleware)
  end

  def test_active_record_has_a_cache_store
    assert(ActiveRecord::Base.respond_to?(:cache_store))
    assert(ActiveRecord::Base.new.respond_to?(:cache_store))
  end

  def test_action_controller_includes_cacheable
    assert_includes(ActionController::Base, ResponseBank::Controller)
  end
end
