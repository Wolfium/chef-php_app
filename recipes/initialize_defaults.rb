node['app']['list'].each do |app_name|
  unless node[app_name].attribute?('user') || node['app']['default_settings'].attribute?('user')
    node.default[app_name]['user'] = app_name
  end

  unless node[app_name].attribute?('group') || node['app']['default_settings'].attribute?('group')
    node.default[app_name]['group'] = node[app_name]['user']
  end
end

if node['app']['install_mysql']
  include_recipe 'mysql::server'
end

# Install Mysql Server before other recipes
if (node.recipe?('mysql::server') || node['app']['install_mysql']) && node.recipe?('php_app::db')
  node.set['app']['default_settings']['db']['host'] = node['app']['default_settings']['db']['host'] || 'localhost'
  node.set['app']['default_settings']['db']['root_user'] = node['app']['default_settings']['db']['root_user'] || 'root'
  node.set['app']['default_settings']['db']['root_password'] = node['app']['default_settings']['db']['root_password'] || node['mysql']['server_root_password']
elsif node.recipe?('php_app::db')
  node['app']['list'].each do |app_name|
    missing_attributes = []
    unless node[app_name]['db'].nil? || node[app_name]['db']['name'].nil?
      %w(host root_user root_password).each do |property|
        no_property=(node[app_name]['db'].nil? || node[app_name]['db'][property].nil?)
        no_property=no_property && (node['app']['default_settings']['db'][property].nil?)
        if no_property
          missing_attributes.push(property)
        end
      end
    end

    unless missing_attributes.empty?
      Chef::Application.fatal! "You must set #{missing_attributes.join(', ')} for your application database"
    end
  end
end

