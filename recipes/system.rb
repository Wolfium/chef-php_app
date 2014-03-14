include_recipe 'php_app::default'

node['app']['list'].each do |app_name|
  app_settings = node['app']['default_settings'].to_hash_recursive
  if node.attribute?(app_name.to_sym)
    app_settings = app_settings.merge_recursive(node[app_name.to_sym].to_hash_recursive)
  end

  unless app_settings['group'] == nil
    group app_settings['group'] do
      gid    app_settings['gid']
      system true
    end
  end

  unless app_settings['user'] == nil
    user app_settings['user'] do
      uid   app_settings['uid']
      group app_settings['group']
      system true
      shell "/bin/bash"
    end
  end
end
