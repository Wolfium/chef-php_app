# PHP Application Cookbook
Set of recipes that prepare full stack environment based on nginx+php-fpm. Suppports pear, composer and other nice features.

# Requirements
* Virtualbox
* Vagrant
* Vagrant plugins
    * Berkshelf (`vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1`)
    * Hostmanger plugin (`vagrant plugin install hostmanager`) (*nix only)
    * Omnibus installer (`vagrant plugin install vagrant-omnibus`)

# Usage
* Example of configuration for Magento project
Berksfile
```ruby
site :opscode

cookbook "php_app", git: "git@github.com:IvanChepurnyi/chef-php_app.git"
```
Vagrantfile
```ruby
required_plugins={
    'vagrant-berkshelf' => 'Berkshelf',
    'vagrant-omnibus' => 'Omnibus',
    'vagrant-hostmanager' => 'Hostmanager'
}


required_plugins.each do |key, value|
  unless Vagrant.has_plugin?(key)
    raise "#{value} plugin should be installed. Use \"vagrant plugin install #{key}\" in order to install it"
  end
end

magentoConfig = {}
magentoConfig['env'] = 'dev' # your environment type 
magentoConfig['name'] = 'magento' # your project name
magentoConfig['sysname'] = "#{magentoConfig['name']}-#{magentoConfig['env']}" # system hostname
magentoConfig['domain'] = '#{magentoConfig['name']}.#{magentoConfig['env']}' # main domain
magentoConfig['domains'] = [] # additional domains if needed
magentoConfig['vhost_include'] = nil
magentoConfig['fastcgi_directives'] = {}

## If you need multi-store for your website use the following method
## - Create a file in your project .conf/domain_map.dev
## - specify magentoConfig['vhost_include'] = "/vagrant/.conf/domain_map.#{magentoConfig['env']}"
## - specify in your file custom map variable for hostmapping
## - use this variable in magentoConfig['fastcgi_directives'] = ['fastcgi_param  MAGE_RUN_CODE $your_var_code', 'fastcgi_param  MAGE_RUN_TYPE $your_var_type']


magentoConfig['memory'] = '2048' # VM memory size
magentoConfig['cpu'] = '4' # number of cpus dedicated to your VM

magentoConfig['mysql_password'] = '' # Mysql root password
magentoConfig['mysqlMemory'] = '1024M' # memory dedicated to buffer pool in mysql
magentoConfig['dbname'] = "#{magentoConfig['env']}_#{magentoConfig['name']}" #  mysql database name

magentoConfig['ip'] = '33.33.33.2' # Your vm IP address, change to unique one for each project
magentoConfig['externalIps'] = ['33.33.33.1', '127.0.0.1'] # Ip addresses which are allowed to access /status and /ping url
magentoConfig['chef_log_level'] = :debug
magentoConfig['directory'] = '' # directory of Magento, 
                                # if empty /vagrant is used. If starts from /, 
                                # then treated as absolute path
magentoConfig['uid'] = 501 # change to your current user uid (required for correct permissions on files)
magentoConfig['mount_dirs'] = {
    '.' => '/vagrant'
}

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.hostname = "#{magentoConfig['sysname']}"
  config.vm.boot_timeout = 60

  # Box that is used for chef
  config.vm.box = "chef-debian-7.4"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.4_chef-provisionerless.box"
  config.vm.network :private_network, ip: "#{magentoConfig['ip']}"
  
  magentoConfig['mount_dirs'].each do |local, guest|
    config.vm.synced_folder local, guest, nfs: true, mount_options: ["nolock", "async"], bsd__nfs_options: ["alldirs","async","nolock"]
  end 
  
  config.vm.provider :virtualbox do |vb|
     vb.customize ["modifyvm", :id, "--memory", "#{magentoConfig['memory']}", "--cpus", "#{magentoConfig['cpu']}"]
  end

  chefJson = {
      'mysql' => {
          'server_debian_password' => magentoConfig['mysql_password'],
          'server_root_password' => magentoConfig['mysql_password'],
          'server_repl_password' => magentoConfig['mysql_password'],
          'bind_address' => '127.0.0.1',
          'remove_test_database' => true,
          'remove_anonymous_users' => true,
          'tunable' => {
              'innodb_buffer_pool_size' => magentoConfig['mysqlMemory'],
              'innodb_buffer_pool_instances' => '1'
          }
      },
      'app' => {
          'php' => '5.4',
          'list' => [magentoConfig['name']],
          'default_settings' => {
              'vhost' => {
                  'status_ip' => magentoConfig['externalIps']
              }
          },
          'pear_packages' => {
              'zendopcache' => {
                  'preferred_state' => 'beta',
                  'zend_extensions' => ['opcache.so']
              }
          }
      },
      'php' => {
          'directives' => {
              'opcache.memory_consumption' => '128',
              'opcache.interned_strings_buffer' => '8',
              'opcache.max_accelerated_files' => '4000',
              'opcache.revalidate_freq' => '60',
              'opcache.fast_shutdown' => '1',
              'opcache.enable_cli' => '1',
              'opcache.enable_file_override' => '1'
          }
      }
  }

  if magentoConfig['env'] == 'dev'
    chefJson['app']['pear_packages']['xhprof'] = {
        'directives' => {
            'output_dir' => '/vagrant/.profiler/'
        },
        'preferred_state' => 'beta'
    }
    chefJson['app']['pear_packages']['xdebug'] = {
        'zend_extensions' => ['xdebug.so'],
        'preferred_state' => 'beta'
    }
  end

  if magentoConfig.has_key?('php_packages')
    if magentoConfig['php_packages'].is_a?(Array)
      magentoConfig['php_packages'].each do |package|
         chefJson['app']['pear_packages'][package] = {}
      end
    elsif magentoConfig['php_packages'].is_a?(Hash)
      magentoConfig['php_packages'].each do |package, config|
        chefJson['app']['pear_packages'][package] = config
      end
    end
  end

  chefJson[magentoConfig['name']] = {
     'directory' => magentoConfig['directory'],
     'uid' => magentoConfig['uid'],
     'vhost' => {
         'domain' => magentoConfig['domain'],
         'domains' => magentoConfig['domains']
     },
     'db' => {
         'name' => magentoConfig['dbname']
     }
  }
  
  if magentoConfig['env'] == 'dev'
     chefJson[magentoConfig['name']]['fastcgi_params'] = {
         'MAGE_IS_DEVELOPER_MODE' => '1'
     }
  end
  
  chefJson[magentoConfig['name']]['deny_paths'] = [
      '/app/', '/includes/', '/lib/', '/media/downloadable/', '/pkginfo/', '/report/config.xml', '/var/'
  ]     
  
  config.vm.provision :chef_solo do |chef|
    chef.log_level = magentoConfig['chef_log_level']
    chef.json = chefJson
    chef.run_list = %w(recipe[apt] recipe[apt] recipe[php_app::app] recipe[php_app::db])
  end

  aliases = magentoConfig['domains']
  aliases.push(magentoConfig['domain'])
  config.hostmanager.aliases = aliases
end

```

# Attributes


# Recipes
- php_app::app (default)
- php_app::db

# Author 
[Ivan Chepurnyi](https://github.com/IvanChepurnyi)

