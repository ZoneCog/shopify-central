require_relative 'test_helper'

class TestDatasources < TableauTest

  def test_datasource_gets_created
    VCR.use_cassette("tableau_datasource_create", :erb => true) do
      project_id = @client.projects.all[:projects].detect{|i| i[:name] == "foobartest"}[:id]
      result = @client.datasources.create(admin_password: ENV['TABLEAU_ADMIN_PASSWORD'], admin_username: ENV['TABLEAU_ADMIN_USER'], project_id: project_id, workbook_name: "fooboy", site_id: @client.site_id, file_path: File.dirname(__FILE__) + "/TestDatasource.tds")
      expected_result_hash = { id: "369d8420-bf64-4771-a2a2-17d80f25b5ba", 
                               name: "TestDatasource", type: "excel",
                               owner: {id: "cf68994e-29c8-4f41-bf6c-398e3666131e"},
                               project: {id: "dfcab774-fc18-45ce-b534-05587c283801", name: "foobartest"},
                               tags: []
                             }
      assert_equal expected_result_hash, result
    end
  end

  def test_datasource_gets_created_with_data
    VCR.use_cassette("tableau_datasource_create", :erb => true) do
      project_id = @client.projects.all[:projects].detect{|i| i[:name] == "foobartest"}[:id]
      file_hash = { :name => "TestDatasource.tds", :data => File.read(File.dirname(__FILE__) + "/TestDatasource.tds")}
      result = @client.datasources.create(admin_password: ENV['TABLEAU_ADMIN_PASSWORD'], admin_username: ENV['TABLEAU_ADMIN_USER'], project_id: project_id, workbook_name: "fooboy", site_id: @client.site_id, :file => file_hash)
      expected_result_hash = { id: "369d8420-bf64-4771-a2a2-17d80f25b5ba", 
                               name: "TestDatasource", type: "excel",
                               owner: {id: "cf68994e-29c8-4f41-bf6c-398e3666131e"},
                               project: {id: "dfcab774-fc18-45ce-b534-05587c283801", name: "foobartest"},
                               tags: []
                             }
      assert_equal expected_result_hash, result
    end
  end

end

  