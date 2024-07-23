require File.expand_path('../../spec_helper.rb', __FILE__)

RSpec.describe ChefGit::DataBagItem do
  context 'chef_git_use_solo' do
    it 'uses solo if data bag is not encrypted' do
      expect(ChefGit::DataBagItem.chef_git_use_solo?('test', 'plain')).to be true
    end

    it 'uses the chef server if the data bag is encrypted' do
      expect(ChefGit::DataBagItem.chef_git_use_solo?('test', 'encrypted')).to be false
    end

  end
end
