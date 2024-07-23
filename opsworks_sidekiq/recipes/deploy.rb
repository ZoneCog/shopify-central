# Adapted from deploy::rails: https://github.com/aws/opsworks-cookbooks/blob/master/deploy/recipes/rails.rb

node[:deploy].each do |application, deploy|

  include_recipe "opsworks_sidekiq::setup"
  
  execute "start sidekiq for app #{application}" do
    command node[:sidekiq][application][:restart_command]
  end
end
