# frozen_string_literal: true

require "test_helper"

module IdentityCache
  module LoadStrategy
    class LoadRequestTest < IdentityCache::TestCase
      def test_db_keys
        db_keys = [1, 2, 3]
        load_request = LoadRequest.new(db_keys, proc {})

        assert_equal(db_keys, load_request.db_keys)
      end

      def test_after_load
        callback = proc {}
        callback.expects(:call).with([:the, :stuff]).returns([:other, :stuff])

        load_request = LoadRequest.new([], callback)
        assert_equal([:other, :stuff], load_request.after_load([:the, :stuff]))
      end
    end
  end
end
