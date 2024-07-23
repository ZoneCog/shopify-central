require_relative 'test_helper'

class TestProjects < TableauTest
  def test_project_create_find_and_delete
    VCR.use_cassette("tableau_project_create_find_delete", :erb => true) do
      mytest = "project_test_time"
      result_id = @client.projects.create(name: mytest, description: "test what do you want from me")
      assert result_id
      project_id = @client.projects.find_by(name: mytest)[:id]
      assert_equal project_id, result_id

      assert @client.projects.delete(id: project_id)
    end
  end

  def test_project_listing
    VCR.use_cassette("tableau_project_list", :erb => true) do
      all_projects = @client.projects.all
      assert all_projects[:projects].is_a? Array
      assert all_projects[:projects].size() > 0
    end
  end
end
