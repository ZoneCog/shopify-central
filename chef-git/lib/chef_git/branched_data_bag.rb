require 'chef/node'
require 'mixlib/shellout'

module ChefGit::BranchedDataBag
  extend self

  def bag_name(data_bag)
    if chef_git_environment == 'master'
      return data_bag
    elsif data_bag_changed?(data_bag)
      bag = "#{chef_git_environment}__#{data_bag}"
      # Chef::DataBag.load returns an empty hash if the data bag is not on the server
      if Chef::DataBag.load(bag).empty?
        return data_bag
      else
        return bag
      end
    else
      return data_bag
    end
  end

  private

  def data_bag_changed?(data_bag)
    Dir.chdir(ChefGit::REPO_PATH) do
      git_diff = Mixlib::ShellOut.new("git rev-list --left-right --count origin/master...HEAD data_bags/#{data_bag}")
      git_diff.run_command
      _master, branched = git_diff.stdout.split(/\s+/).map(&:to_i)
      unchanged = !git_diff.error? && branched == 0
      return !unchanged
    end
  end

  def chef_git_environment
    @branch ||= begin
      # If the branch is specified in client.rb or -E flag, use that
      if Chef::Config.environment
        Chef::Config.environment
      # Otherwise, look up the node
      else
        node = Chef::Node.load(Chef::Config[:node_name])
        node.chef_environment
      end
    end
  end
end
