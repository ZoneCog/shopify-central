module Helpers
  module Collectd
    require 'chef/mixin/shell_out'
    include Chef::Mixin::ShellOut
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def collectd_config_parses?
      ccp = shell_out("#{node['collectd']['sbin_dir']}/collectd -t")
      ccp.exitstatus == 0
    end

  end
end
