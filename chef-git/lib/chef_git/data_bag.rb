require 'chef/data_bag'

# We are forcing chef solo mode so that we use the data bags from git instead of trying to use the server
# https://github.com/chef/chef/blob/db57131ad383076391b9df32d5e9989cfb312d58/lib/chef/data_bag.rb#L119-L144

class ChefGit::DataBag < Chef::DataBag
  def self.load(name)
    Chef::Config[:solo_legacy_mode] = true
    result = super
    Chef::Config[:solo_legacy_mode] = false
    return result
  end
end
