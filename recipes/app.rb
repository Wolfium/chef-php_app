include_recipe "php_app::system"

php_version = node['app']['php']

rise 'PHP version is unknown' unless node['php_versions'].attribute?(php_version)

# install the required php version
node.override['php']['install_method'] = 'source'
node.override['php']['version'] = node['php_versions'][php_version]['version']
node.override['php']['checksum'] = node['php_versions'][php_version]['checksum']
# Install fpm with all dependencies
include_recipe 'php_app::install_fpm'

node['app']['pear_channels'].each do |url|
  php_pear_channel url do
    action :discover
  end
end

node['app']['pear_packages'].each do |name, options|
  php_pear name do
    action :install
    options.each do |option_name, option_value|
      send(option_name.to_sym, option_value) if respond_to?(option_name.to_sym)
    end
    unless options.key?('channel')
      notifies :restart, 'service[php-app-fpm]', :delayed
    end
  end
end

if node['app']['composer']
  include_recipe 'composer'
end

# Install nginx
node.override['nginx']['default_site_enabled'] = false

include_recipe 'nginx'

fpm_port = 9001

node['app']['list'].each do |app_name|
  app_settings = node['app']['default_settings'].to_hash_recursive
  if node.attribute?(app_name.to_sym)
    app_settings = app_settings.merge_recursive(node[app_name.to_sym].to_hash_recursive)
  end

  if app_settings['socket'] && app_settings['use_fpm']
    socket_path = "#{node['php']['fpm_socket_path']}/php-fpm.#{app_name}.sock";
    app_settings['fpm']['listen'] = socket_path
    app_settings['vhost']['fastcgi_pass'] = "unix:/#{socket_path}"
    app_settings['fpm']['listen_params'] = app_settings['fpm']['listen_params'] || {}
    app_settings['fpm']['listen_params']['owner'] = node['nginx']['user']
    app_settings['fpm']['listen_params']['group'] = node['nginx']['group']
    app_settings['fpm']['listen_params']['mode'] = '0644'
  elsif app_settings['use_fpm']
    listen = app_settings['fpm']['listen'] || "127.0.0.1:#{fpm_port}"
    app_settings['fpm']['listen'] = listen
    app_settings['vhost']['fastcgi_pass'] = listen
    fpm_port += 1
  else
    app_settings['vhost']['fastcgi_pass'] = nil
  end

  unless app_settings['vhost']['domain']
    app_settings['vhost']['domain'] = "#{app_name}.dev"
  end
  unless app_settings['vhost']['domains'].is_a?(Array)
    app_settings['vhost']['domains'] = []
  end

  app_settings['vhost']['domains'].push(app_settings['vhost']['domain'])


  app_directory = app_settings['directory']

  unless /^\// =~ app_directory
    app_directory = "#{node['app']['root_directory']}/#{app_directory}"
  end

  app_settings['vhost']['directory'] = app_directory

  unless app_settings['fpm']['user']
    app_settings['fpm']['user'] = app_settings['user']
  end

  unless app_settings['fpm']['group']
    app_settings['fpm']['group'] = app_settings['group']
  end

  if app_settings['chroot']
    app_settings['fpm']['chroot'] = app_directory
    unless app_settings['chroot'].is_a?(TrueClass)
      app_settings['fpm']['chroot'] = app_settings['chroot']
    end

    if app_settings['chdir'].is_a?(TrueClass)
      app_settings['chdir'] = '/'
    end
  end

  if app_settings['chdir']
    app_settings['fpm']['chdir'] = app_directory
    unless app_settings['chdir'].is_a?(TrueClass)
      app_settings['fpm']['chdir'] = app_settings['chdir']
    end
  end

  if app_settings['use_fpm']
    php_app_fpm_pool "#{app_name}" do
      action :create
      app_settings['fpm'].each do |key, value|
        send(key.to_sym, value)
      end
      notifies [:start, :reload], "service[php-app-fpm]", :delayed
    end

    if node['app']['composer'] && ::File::exists?("#{app_directory}/#{app_settings['composer_location']}")
      composer_directory=::File::dirname(
          ::File::realdirpath("#{app_directory}/#{app_settings['composer_location']}")
      )
      bash "composer-dependencies-#{app_name}" do
        cwd composer_directory
        code "composer install #{app_settings['composer_options']}"
        user app_settings['user']
        group app_settings['group']
      end
    end
  end
  php_app_vhost "#{app_name}" do
    action :create
    app_settings['vhost'].each do |key, value|
      send(key.to_sym, value)
    end
    notifies :reload, "service[nginx]", :delayed
  end


end





