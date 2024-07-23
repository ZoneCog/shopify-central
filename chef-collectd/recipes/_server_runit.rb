#
# Cookbook Name:: collectd
# Recipe:: _server_runit

include_recipe "runit"

runit_service "collectd"
