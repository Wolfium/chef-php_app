action :create do

  @is_updated = false
  if new_resource.ssl
    @ssl_name = if new_resource.ssl['name']
                 new_resource.ssl['name']
               else
                 new_resource.name
               end

    @resource = directory "#{node[:nginx][:dir]}/ssl" do
      owner node[:nginx][:user]
      group node[:nginx][:group]
      mode '0755'
    end

    @is_updated = @is_updated || @resource.updated_by_last_action?

    @resource = file "#{node[:nginx][:dir]}/ssl/#{@ssl_name}.public.crt" do
      owner node[:nginx][:user]
      group node[:nginx][:group]
      mode '0640'
      content  <<-EOH
# Managed by Chef.  Local changes will be overwritten.
#{new_resource.ssl['public']}
      EOH
    end

    @is_updated = @is_updated || @resource.updated_by_last_action?

    @resource = file "#{node[:nginx][:dir]}/ssl/#{@ssl_name}.private.key" do
      owner node[:nginx][:user]
      group node[:nginx][:group]
      mode '0640'
      content <<-EOH
# Maintained by Chef.  Local changes will be overwritten.
#{new_resource.ssl['private']}
      EOH
    end

    @is_updated = @is_updated || @resource.updated_by_last_action?

    new_resource.ssl.merge!({
      :certificate => "#{node[:nginx][:dir]}/ssl/#{ssl_name}.public.crt",
      :certificate_key => "#{node[:nginx][:dir]}/ssl/#{ssl_name}.private.key"
    })
  end

  @resource = template "#{node[:nginx][:dir]}/sites-available/#{new_resource.name}.tld" do
    owner node[:nginx][:user]
    group node[:nginx][:group]
    mode '755'
    source 'nginx_vhost.conf.erb'
    variables(
        params: new_resource
    )
    notifies :reload, 'service[nginx]', :delayed
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?

  @resource = link "#{node[:nginx][:dir]}/sites-enabled/#{new_resource.name}.tld" do
    to "#{node[:nginx][:dir]}/sites-available/#{new_resource.name}.tld"
    only_if { new_resource.enabled }
    notifies :reload, 'service[nginx]', :delayed
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?

  new_resource.updated_by_last_action(@is_updated)
end

action :delete do
  @conf_name = new_resource.name

  @is_updated = false

  @resource = link "#{node[:nginx][:dir]}/sites-enabled/#{@conf_name}.tld" do
    to "#{node[:nginx][:dir]}/sites-available/#{@conf_name}.tld"
    action :delete
    notifies :reload, 'service[nginx]', :delayed
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?

  @resource = file "#{node[:nginx][:dir]}/sites-available/#{@conf_name}.tld" do
    action :delete
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?

  new_resource.updated_by_last_action(@is_updated)
end

action :enable do
  @conf_name = new_resource.name

  @is_updated = false

  @resource = link "#{node[:nginx][:dir]}/sites-enabled/#{conf_name}.tld" do
    to "#{node[:nginx][:dir]}/sites-available/#{conf_name}.tld"
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?
  new_resource.updated_by_last_action(@is_updated)
end

action :disable do
  @conf_name = new_resource.name

  @is_updated = false

  @resource = link "#{node[:nginx][:dir]}/sites-enabled/#{@conf_name}.tld" do
    to "#{node[:nginx][:dir]}/sites-available/#{@conf_name}.tld"
    action :delete
    notifies :reload, 'service[nginx]', :delayed
  end

  @is_updated = @is_updated || @resource.updated_by_last_action?
  new_resource.updated_by_last_action(@is_updated)
end