
require File.expand_path('../support/helpers',__FILE__)

describe 'collectd::client_collectd' do
  include Helpers::Collectd

  it 'creates network.conf' do
    file("#{node['collectd']['plugconf_dir']}/network.conf").must_exist
  end
end
