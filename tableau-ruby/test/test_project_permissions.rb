require_relative 'test_helper'

class TestProjectPermissions < TableauTest
  def test_project_add_permissions_for_users
    VCR.use_cassette("tableau_project_add_permissions", :erb => true) do
      params = {
        :project_id => 'dfcab774-fc18-45ce-b534-05587c283801',
        :user_id => '0540525d-b635-4a1a-825e-acb6a1767175',
        :permissions => {
          :allow => ["AddComment", "Connect", "ExportData", "ExportImage", "Filter", "Read", "ViewComments"],
          :deny => []
        }
      }
      result = @client.projects.add_permissions_for_user(params)

      assert_equal params[:permissions][:allow], result.css('tsResponse permissions capabilities capability').map {|c| c[:name]}.sort
    end
  end

  def test_project_add_permissions_for_groups
    VCR.use_cassette("tableau_project_add_permissions_for_group", :erb => true) do
      params = {
        :project_id => 'dfcab774-fc18-45ce-b534-05587c283801',
        :permissions => {
          :allow => ["AddComment", "Connect", "ExportData", "ExportImage", "Filter", "Read", "ViewComments"],
          :deny => []
        }
      }

      result = @client.projects.add_permissions_for_group(params)
      assert_equal params[:permissions][:allow], result.css('tsResponse permissions capabilities capability').map {|c| c[:name]}.sort
    end
  end
end