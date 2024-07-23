#
# Cookbook Name:: collectd
# Recipe:: _server_logrotate
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
#

include_recipe 'collectd::_server_logrotate'

log_file = "#{ node['collectd']['log_dir'] }/#{ node['collectd']['log_file'] }"

directory node['collectd']['log_dir'] do
  owner 'root'
  group 'root'
  mode 0755
end

collectd_plugin 'logfile' do
  options :loglevel => node['collectd']['log_level'],
    :file => log_file,
    :timestamp => node['collectd']['log_timestamp'],
    :printseverity => node['collectd']['log_print_severity']
end
