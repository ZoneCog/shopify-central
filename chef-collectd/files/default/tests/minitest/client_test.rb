require File.expand_path('../support/helpers', __FILE__)

describe 'collectd::client' do
  include Helpers::Collectd

  it 'starts collectd' do
    service('collectd').must_be_running
  end

  it 'enables collectd' do
    service('collectd').must_be_enabled
  end

  describe 'collectd::_install_from_package' do
    it 'installs collectd' do
      package('collectd').must_be_installed
    end
  end

  describe 'collectd::_server_conf' do
    it 'creates the sysconf_dir' do
      directory(node['collectd']['sysconf_dir']).must_exist
    end

    it 'creates the plugconf_dir' do
      directory(node['collectd']['plugconf_dir']).must_exist
    end

    it 'creates collectd.conf' do
      file("#{node['collectd']['sysconf_dir']}/collectd.conf").must_exist
    end

    it 'creates thresholds.conf' do
      file("#{node['collectd']['sysconf_dir']}/thresholds.conf").must_exist
    end

    it 'creates a valid configuration' do
      collectd_config_parses?
    end
  end

end
