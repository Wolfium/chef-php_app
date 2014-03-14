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

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = "php-app-berkshelf"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "chef-debian-7.4"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.4_chef-provisionerless.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: "33.33.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider :virtualbox do |vb|
     # Don't boot with headless mode
     # vb.gui = true

     # Use VBoxManage to customize the VM. For example to change memory:
     vb.customize ["modifyvm", :id, "--memory", "2048", "--cpus", "4"]
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.vm.boot_timeout = 60

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug

    chef.json = {
        'mysql' => {
            'server_debian_password' => 'my_root_password',
            'server_root_password' => 'my_root_password',
            'server_repl_password' => 'my_root_password'
        },
        'app' => {
            'list' => ['testapp', 'testapp2', 'teststatic'],
            'default_settings' => {
                'vhost' => {
                  'status_ip' => %w(33.33.33.1)
                }
            },
            'pear_channels' => ['pear.phpunit.de', 'pear.symfony.com'],
            'pear_packages' => {
                'xdebug' => {
                    'zend_extensions' => ['xdebug.so']
                },
                'zendopcache' => {
                    'zend_extensions' => ['opcache.so'],
                    'preferred_state' => 'beta'
                },
                'PHPUnit' => {
                    'channel' => 'pear.phpunit.de',
                    'version' => '3.7.28'
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
        },
        'testapp' => {
            'db' => {
                'name' => 'test_app'
            },
            'domains' => ['test-app1.dev', 'test-app2.dev'],
            'socket' => false
        },
        'testapp2' => {
           'db' => {
              'name' => 'test_app2'
           }
        },
        'teststatic' => {
           'use_fpm' => false
        }
    }
    chef.run_list = %w(recipe[apt] recipe[apt] recipe[php_app::app] recipe[php_app::db])
  end

  config.hostmanager.aliases = %w(testapp.dev testapp2.dev test-app1.dev test-app2.dev teststatic.dev)
end
