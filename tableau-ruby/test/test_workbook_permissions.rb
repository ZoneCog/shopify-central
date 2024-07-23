require_relative 'test_helper'

class TestWorkbookPermissions < TableauTest
  def test_workbook_add_permissions

    VCR.use_cassette("tableau_workbook_add_permissions", :erb => true) do
      params = {
        :workbook_id => 'ab328f38-ff41-4707-8999-b91729784d02',
        :user_id => '0540525d-b635-4a1a-825e-acb6a1767175',
        :permissions => {
          :allow => ["AddComment", "ExportData", "ExportImage", "Filter", "Read", "ViewComments"],
          :deny => []
        }
      }

      result = @client.workbooks.add_permissions_for_user(params)

      assert_equal params[:permissions][:allow], result.css('tsResponse permissions capabilities capability').map {|c| c[:name]}.sort
    end
  end

  def test_workbook_add_group_permissions

    VCR.use_cassette("tableau_workbook_add_group_permissions", :erb => true) do
      params = {
        :workbook_id => 'ab328f38-ff41-4707-8999-b91729784d02',
        :group_id => '97b96d2e-d7ce-11e3-b3a9-07e2874bf6a7',
        :permissions => {
          :allow => ["AddComment", "ExportData", "ExportImage", "Filter", "Read", "ViewComments"],
          :deny => []
        }
      }

      result = @client.workbooks.add_permissions_for_group(params)

      assert_equal params[:permissions][:allow], result.css('tsResponse permissions capabilities capability').map {|c| c[:name]}.sort
    end
  end
end