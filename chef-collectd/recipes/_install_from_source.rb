#
# Cookbook Name:: collectd
# Recipe:: _install_from_source
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

include_recipe "build-essential"
include_recipe "ark"

package "libprotobuf-c0-dev"
package "protobuf-c-compiler"

node['collectd']['build_prereq_pkgs'].each do |build_pkgs|
  package build_pkgs
end

user_autoconf_options = [
  "--prefix=#{node['collectd']['prefix_dir']}",
  "--sysconfdir=#{node['collectd']['sysconf_dir']}",
  "--bindir=#{node['collectd']['bin_dir']}",
  "--enable-write-riemann"
]

unless node['collectd']['autoconf_opts'].nil?
  node['collectd']['autoconf_opts'].each { |aco| user_autoconf_options << aco }
end

tar_file = [
  node['collectd']['source_tar_name_prefix'],
  node['collectd']['version'],
  node['collectd']['source_tar_name_extension']
].join("")
tar_source_url = "#{node['collectd']['source_url_prefix']}/#{tar_file}"

remote_file "/usr/local/src/#{node['collectd']['source_tar_name_prefix']}#{node['collectd']['version']}" do
  source tar_source_url
  not_if "test -d /usr/local/src/#{node['collectd']['source_tar_name_prefix']}#{node['collectd']['version']}"
end

execute "unpack collectd" do
  cwd "/usr/local/src/"
  command "tar xvfz #{node['collectd']['source_tar_name_prefix']}#{node['collectd']['version']}"
  not_if "test -d /usr/local/src/#{node['collectd']['source_tar_name_prefix']}#{node['collectd']['version']}"
end

execute "compile and install collectd" do
  cwd "/usr/local/src/#{node['collectd']['source_tar_name_prefix']}#{node['collectd']['version']}"
  command "./configure #{user_autoconf_options.join(' ')} && make && make install"
  not_if "collectd -h | grep #{node['collectd']['version']}"
end
