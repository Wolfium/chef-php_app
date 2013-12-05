include_recipe "php"

bash "copy init.d deamon php" do
  cwd Chef::Config[:file_cache_path]
end

php_fpm_service_name = value_for_platform_family(
    %w(rhel fedora) => 'php-fpm',
    'default' => 'php5-fpm'
)

# The generic server config
template "/etc/init.d/#{php_fpm_service_name}" do
  source 'php-fpm.init.d.erb'
  owner 'root'
  group 'root'
  mode 00755
  variables(
      :service_name => php_fpm_service_name
  )
end

service 'php-app-fpm' do
  case node['platform_family']
    when 'rhel', 'fedora'
      service_name php_fpm_service_name
    else
      service_name php_fpm_service_name
  end
  supports :restart => true, :start => true, :stop => true, :status => true, :reload => true
  action :enable
end

# This deletes the default FPM profile. Please use the fpm LWRP to define FPM pools
file "#{node['php']['fpm_pool_dir']}/www.conf" do
  action :delete
end

directory "#{node['php']['fpm_conf_dir']}" do
  action :create
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  not_if do ::File.exists?(node['php']['fpm_conf_dir']) end
end

directory "#{node['php']['fpm_pool_dir']}" do
  action :create
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  not_if do ::File.exists?(node['php']['fpm_pool_dir']) end
end

# Ubuntu uses a separate ini for FPM
template "#{node['php']['fpm_conf_dir']}/php.ini" do
  source 'php.ini.erb'
  cookbook 'php'
  owner 'root'
  group 'root'
  notifies :restart, "service[php-app-fpm]"
  mode 00644
  variables(:directives => node['php']['directives'])
  only_if { platform_family?('debian') }
end

# The generic server config
template "#{node['php']['fpm_conf_dir']}/php-fpm.conf" do
  source 'php-fpm.conf.erb'
  owner 'root'
  group 'root'
  notifies :restart, "service[php-app-fpm]"
  mode 00644
end



# For the pool log files
directory node['php']['fpm_log_dir'] do
  owner 'root'
  group 'root'
  mode 01733
  action :create
end

# Log rotation file
template node['php']['fpm_rotfile'] do
  source 'php-fpm.logrotate.erb'
  owner 'root'
  group 'root'
  mode 00644
end