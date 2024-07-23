require 'chef_git/branched_data_bag'
require 'chef/encrypted_data_bag_item'

class ChefGit::DataBagItem < Chef::DataBagItem

  def self.load(data_bag, name)
    # We are forcing chef solo mode so that we use the plain data bag items from git
    # If the items are encrypted, we use the chef server
    # https://github.com/chef/chef/blob/db57131ad383076391b9df32d5e9989cfb312d58/lib/chef/data_bag_item.rb#L149-L156

    use_solo = chef_git_use_solo?(data_bag, name)
    unless use_solo
      # If we aren't using solo, we'll see if we need to prefix our data bag with a branch
      data_bag = ChefGit::BranchedDataBag.bag_name(data_bag)
    end

    Chef::Config[:solo_legacy_mode] = use_solo
    result = super
    Chef::Config[:solo_legacy_mode] = false
    return result
  end

  def self.chef_git_use_solo?(data_bag, name)
    item_file = File.join(Chef::Config[:data_bag_path], data_bag, "#{name}.json")
    raw_data = Chef::JSONCompat.from_json(IO.read(item_file))
    !ChefGitDataBagEncryptedChecker.encrypted?(raw_data)
  end

  module ChefGitDataBagEncryptedChecker
    extend Chef::EncryptedDataBagItem::CheckEncrypted
  end
end
