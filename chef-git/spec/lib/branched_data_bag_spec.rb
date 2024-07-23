require File.expand_path('../../spec_helper.rb', __FILE__)

RSpec.describe ChefGit::BranchedDataBag do

  context 'is on master' do
    before do
      allow_any_instance_of(ChefGit::BranchedDataBag).to receive(:chef_git_environment).and_return('master')
    end

    it 'returns the data bag name if on master' do
      expect(ChefGit::BranchedDataBag.bag_name('foo')).to eq('foo')
    end
  end

  context 'branched data bag ahead of master' do
    before do
      allow_any_instance_of(ChefGit::BranchedDataBag).to receive(:chef_git_environment).and_return('notmaster')
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return("0\t3")
      allow(Chef::DataBag).to receive(:load).and_return({'foo' => 'bar'})
      Dir.stub(:chdir).and_yield
    end

    it 'returns the data bag name prefixed by the branch' do
      expect(ChefGit::BranchedDataBag.bag_name('foo')).to eq('notmaster__foo')
    end
  end

  context 'branched data bag matches master' do
    before do
      allow_any_instance_of(ChefGit::BranchedDataBag).to receive(:chef_git_environment).and_return('notmaster')
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return("0\t0")
      allow_any_instance_of(Mixlib::ShellOut).to receive(:error?).and_return(false)
      Dir.stub(:chdir).and_yield
    end

    it 'returns the data bag name not prefixed by branch branch' do
      expect(ChefGit::BranchedDataBag.bag_name('foo')).to eq('foo')
    end

  end

  context 'branched data bag behind master' do
    before do
      allow_any_instance_of(ChefGit::BranchedDataBag).to receive(:chef_git_environment).and_return('notmaster')
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return("3\t0")
      allow_any_instance_of(Mixlib::ShellOut).to receive(:error?).and_return(false)
      Dir.stub(:chdir).and_yield
    end

    it 'returns the data bag name not prefixed by branch branch' do
      expect(ChefGit::BranchedDataBag.bag_name('foo')).to eq('foo')
    end

  end

  context 'branched data bag not on chef server' do
    before do
      allow_any_instance_of(ChefGit::BranchedDataBag).to receive(:chef_git_environment).and_return('notmaster')
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return("0\t3")
      allow_any_instance_of(Mixlib::ShellOut).to receive(:error?).and_return(false)
      allow(Chef::DataBag).to receive(:load).and_return({})
      Dir.stub(:chdir).and_yield
    end

    it 'returns the data bag name not prefixed by branch branch' do
      expect(ChefGit::BranchedDataBag.bag_name('foo')).to eq('foo')
    end
  end

  context 'branched data bag on the chef server' do
    before do
      allow_any_instance_of(ChefGit::BranchedDataBag).to receive(:chef_git_environment).and_return('notmaster')
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return("0\t3")
      allow_any_instance_of(Mixlib::ShellOut).to receive(:error?).and_return(false)
      allow(Chef::DataBag).to receive(:load).and_return({'foo' => 'bar'})
      Dir.stub(:chdir).and_yield
    end

    it 'returns the data bag name prefixed by branch branch' do
      expect(ChefGit::BranchedDataBag.bag_name('foo')).to eq('notmaster__foo')
    end
  end
end
