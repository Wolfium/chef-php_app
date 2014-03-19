# -*- mode: ruby -*-
# vi: set ft=ruby :

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
magentoConfig['env'] = 'dev'
magentoConfig['name'] = 'magento'
magentoConfig['sysname'] = "#{magentoConfig['name']}-#{magentoConfig['env']}"
magentoConfig['domain'] = 'checkitout.dev'
magentoConfig['domains'] = []
magentoConfig['dbname'] = "#{magentoConfig['env']}_#{magentoConfig['name']}"
magentoConfig['mysql_password'] = ''
magentoConfig['memory'] = '2048'
magentoConfig['mysqlMemory'] = '1024M'
magentoConfig['cpu'] = '4'
magentoConfig['ip'] = '33.33.33.10'
magentoConfig['externalIps'] = ['33.33.33.1', '127.0.0.1']
magentoConfig['chef_log_level'] = :debug
magentoConfig['directory'] = ''
magentoConfig['uid'] = nil

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


  config.vm.provision :chef_solo do |chef|
    chef.log_level = magentoConfig['chef_log_level']
    chef.json = chefJson
    chef.run_list = %w(recipe[apt] recipe[apt] recipe[php_app::app] recipe[php_app::db])
  end

  aliases = magentoConfig['domains']
  aliases.push(magentoConfig['domain'])
  config.hostmanager.aliases = aliases
end
