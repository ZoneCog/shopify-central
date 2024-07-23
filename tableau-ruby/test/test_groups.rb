require_relative 'test_helper'

class TestDatasources < TableauTest

  def test_groups_all_users_group
    VCR.use_cassette("tableau_groups_all_users_group", :erb => true) do
      result = @client.groups.all_users_group

      assert_equal '97b96d2e-d7ce-11e3-b3a9-07e2874bf6a7', result[:id]
      assert_equal 'All Users', result[:name]
    end
  end
end

