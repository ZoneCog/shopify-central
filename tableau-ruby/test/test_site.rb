require_relative 'test_helper'

class TestSite < TableauTest
  def test_site_finding
    VCR.use_cassette("tableau_site_find", :erb => true) do
      site = @client.sites.find_by(name: ENV['TABLEAU_DEFAULT_SITE'])
      assert site[:name]
      assert site[:id]
    end
  end

  def test_site_listing
    VCR.use_cassette("tableau_site_list", :erb => true) do
      sites = @client.sites.all 
      assert sites[:sites].is_a? Array
    end
  end

  def test_site_create
    VCR.use_cassette("tableau_site_create", :erb => true) do
      @client.token = "f3cd1af458afaf6be8c29f9477d835aa"
      site = @client.sites.create(:name => "API_TEST_SITE", :content_url => "nuclearwar44")
      assert_equal "API_TEST_SITE", site[:name] 
      assert_equal "nuclearwar44", site[:content_url]
      assert_equal "6608f694-fc4e-42a3-a478-5178296dec5d", site[:id]
      assert_equal "Active", site[:state]
    end
  end

  def test_site_delete
    VCR.use_cassette("tableau_site_delete", :erb => true) do
      result = @client.sites.delete(:id => "6608f694-fc4e-42a3-a478-5178296dec5d")
      assert_equal "Site successfully deleted.", result[:success]
    end
  end
end
