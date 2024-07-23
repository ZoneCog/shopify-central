require_relative 'test_helper'

class TestDatasourcePermissions < TableauTest
  def test_datasource_add_permissions

    VCR.use_cassette("tableau_datasource_add_permissions", :erb => true) do
      params = {
        :datasource_id => 'aadedf2b-bf2b-4ea8-8198-cc6ac0e79b21',
        :user_id => '0540525d-b635-4a1a-825e-acb6a1767175',
        :permissions => {
          :allow => ["Connect", "Read"],
          :deny => []
        }
      }

      result = @client.datasources.add_permissions_for_user(params)

      assert_equal params[:permissions][:allow], result.css('tsResponse permissions capabilities capability').map {|c| c[:name]}.sort
    end
  end
end