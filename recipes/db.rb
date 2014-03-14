include_recipe 'php_app::default'
include_recipe 'database::mysql'

node['app']['list'].each do |app_name|
  app_settings = node['app']['default_settings'].to_hash_recursive
  if node.attribute?(app_name.to_sym)
    app_settings = app_settings.merge_recursive(node[app_name.to_sym].to_hash_recursive)
  end

  if app_settings['db']['name']
    unless app_settings['db']['user']
      app_settings['db']['user'] = app_name
    end

    unless app_settings['db']['password']
      app_settings['db']['password'] = app_name
    end

    mysql_connection = {
        :host => app_settings['db']['host'],
        :username => app_settings['db']['root_user'],
        :password => app_settings['db']['root_password']
    }

    mysql_database app_settings['db']['name'] do
      connection mysql_connection
      encoding app_settings['db']['encoding']
      collation app_settings['db']['collation']
    end

    mysql_database_user app_settings['db']['user'] do
      connection    mysql_connection
      password      app_settings['db']['user']
      database_name app_settings['db']['name']
      host          app_settings['db']['userhost']
      privileges    [:all]
      action        [:create, :grant]
    end
  end
end