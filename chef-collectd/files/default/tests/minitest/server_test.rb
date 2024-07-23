
require File.expand_path('../support/helpers',__FILE__)

describe 'collectd::server' do
  include Helpers::Collectd

  it 'creates network.conf' do
    file("#{node['collectd']['plugconf_dir']}/network.conf").must_exist
  end

  describe 'collectd::_server_logfile' do
    it 'creates the log_dir' do
      directory(node['collectd']['log_dir']).must_exist
    end

    it 'creates logfile.conf' do
      file("#{node['collectd']['plugconf_dir']}/logfile.conf").must_exist
    end
  end

end
