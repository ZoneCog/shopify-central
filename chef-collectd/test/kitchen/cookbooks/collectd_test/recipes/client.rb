
include_recipe 'collectd::client'

%w(disk entropy memory swap).each do |plug|
  collectd_plugin plug
end

collectd_plugin 'syslog' do
  options :log_level => 'info',
    :notify_level => 'warning'
end

collectd_plugin 'tcpconns' do
  options :listening_ports => true
end

collectd_plugin 'rrdtool' do
  options :data_dir => node['collectd']['log_dir'],
  :cache_flush => 120,
  :writes_per_second => 50
end
