#
# Cookbook Name:: smokeping
# Recipe:: default
#
# Copyright 2013-2014, Limelight Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'perl'
include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'

%w(fping smokeping curl libauthen-radius-perl libnet-ldap-perl libnet-dns-perl libio-socket-ssl-perl libnet-telnet-perl libsocket6-perl libio-socket-inet6-perl sendmail rrdtool).each do |pkg|
  package pkg do
    action :install
  end
end

# delete the package provided apache config
file '/etc/smokeping/apache2.config' do
  action :delete
end

# find the other smokeping servers
servers = search(:node, 'recipes:smokeping*')

%w(General Targets Alerts).each do |config|
  template "/etc/smokeping/config.d/#{config}" do
    source "#{config}.erb"
    mode '0644'
    variables(
      :nodes => servers,
      :alerts => node['smokeping']['alerts']
    )
    notifies :restart, 'service[smokeping]'
  end
end

service 'smokeping' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

template '/etc/apache2/sites-available/smokeping' do
  source 'apache2.erb'
  mode '0644'
  notifies :reload, 'service[apache2]'
end

apache_site 'smokeping' do
  enable true
end

apache_site '000-default' do
  enable false
end
