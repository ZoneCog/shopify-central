# Cookbook Name:: collectd
# Provider:: plugin
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

action :create do

  directory node['collectd']['plugconf_dir'] do
    recursive true
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  template new_resource.name do
    path "#{node['collectd']['plugconf_dir']}/#{new_resource.name}.conf"
    owner "root"
    group "root"
    mode 0644
    source(new_resource.template || "#{new_resource.type}_conf.erb")
    cookbook new_resource.template ? new_resource.cookbook_name.to_s : 'collectd'
    variables({
      :name => new_resource.name,
      :modules => new_resource.modules,
      :options => new_resource.options
    })
    notifies :restart, "service[collectd]", :delayed
  end
  new_resource.updated_by_last_action(true)
end

action :delete do
  file new_resource.name do
    path "#{node['collectd']['plugconf_dir']}/#{new_resource.name}.conf"
    action :delete
  end
  new_resource.updated_by_last_action(true)
end
