service "monit" do
  supports :status => false, :restart => true, :reload => true
  action :nothing
end


node[:deploy].each do |application, deploy|
  execute "restart Rails app #{application}" do
    command node[:sidekiq][application][:restart_command]
    action :nothing
  end
end
