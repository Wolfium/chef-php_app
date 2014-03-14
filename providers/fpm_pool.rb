action :create do

  @is_updated = false

  @resource = template "#{node['php']['fpm_pool_dir']}/#{new_resource.name}.conf" do
    owner 'root'
    group 'root'
    mode '755'
    source 'fpm_pool.erb'
    cookbook 'php_app'
    variables(
        params: new_resource
    )
    notifies :restart, 'service[php-app-fpm]', :immediate
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?

  new_resource.updated_by_last_action(@is_updated)
end

action :delete do
  @is_updated = false

  @resource = file "#{node['php']['fpm_pool_dir']}/#{new_resource.name}.conf" do
    action :delete
    notifies :restart, 'service[php-app-fpm]', :immediate
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?

  new_resource.updated_by_last_action(@is_updated)
end