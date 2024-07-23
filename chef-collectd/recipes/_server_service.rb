#
# Cookbook Name:: collectd
# Recipe:: _server_service
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

template "/etc/init.d/collectd" do
  source "collectd-init.d.erb"
  owner  "root"
  group  "root"
  mode   0755
end

service 'collectd' do
  supports :restart => true, :status => true
  action [:enable, :start]
end
