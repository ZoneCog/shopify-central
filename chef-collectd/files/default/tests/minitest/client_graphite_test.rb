
require File.expand_path('../support/helpers',__FILE__)

describe 'collectd::client_graphite' do
  include Helpers::Collectd

  it 'creates carbon_writer.conf' do
    file("#{node['collectd']['plugconf_dir']}/carbon_writer.conf").must_exist
  end
end
