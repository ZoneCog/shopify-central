#
# Cookbook Name:: collectd
# Recipe:: _server_conf
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

sysconf = node['collectd']['sysconf_dir']
plugconf = node['collectd']['plugconf_dir']

[sysconf, plugconf].each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

%w(collectd thresholds).each do |file|
  template "#{sysconf}/#{file}.conf" do
    source "#{file}.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, "service[collectd]", :delayed
  end
end
