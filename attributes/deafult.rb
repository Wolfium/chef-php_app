# List of latest available PHP versions with their checksums for download
default['php_versions']['5.3']['version'] = '5.3.28'
default['php_versions']['5.3']['checksum'] = 'eec3fb5ccb6d8c238f973d306bebb00e'
default['php_versions']['5.4']['version'] = '5.4.26'
default['php_versions']['5.4']['checksum'] = '7e5f6254d1bac06efc225259a1e38a27'
default['php_versions']['5.5']['version'] = '5.5.10'
default['php_versions']['5.5']['checksum'] = 'e760656f7cf2f05158f73da75e8b720b'

include_attribute 'php'
case node['platform_family']
  when 'rhel', 'fedora'
    default['php']['fpm_conf_dir']  = '/etc'
    default['php']['fpm_pool_dir']  = '/etc/php-fpm.d'
    default['php']['fpm_log_dir']   = '/var/log/php-fpm'
    default['php']['fpm_rotfile']   = '/etc/logrotate.d/php-fpm'
    default['php']['fpm_socket_path']   = '/var/run'
    default['php']['fpm']['pid']   = '/var/run/php-fpm/php-fpm.pid'
    default['php']['fpm']['error_log']   = '/var/log/php-fpm/fpm-master.log'
  when 'debian'
    default['php']['fpm_conf_dir']  = '/etc/php5/fpm'
    default['php']['fpm_pool_dir']  = '/etc/php5/fpm/pool.d'
    default['php']['fpm_log_dir']   = '/var/log/php5-fpm'
    default['php']['fpm_rotfile']   = '/etc/logrotate.d/php5-fpm'
    default['php']['fpm_socket_path']   = '/var/run'
    default['php']['fpm']['pid']   = '/var/run/php5-fpm.pid'
    default['php']['fpm']['error_log']   = '/var/log/php5-fpm/fpm-master.log'
  else
    default['php']['fpm_conf_dir']  = '/etc/php5/fpm'
    default['php']['fpm_pool_dir']  = '/etc/php5/fpm/pool.d'
    default['php']['fpm_rotfile']   = '/etc/logrotate.d/php5-fpm'
    default['php']['fpm_log_dir']   = '/var/log/php5-fpm'
    default['php']['fpm_socket_path']   = '/var/run'
    default['php']['fpm']['pid']   = '/var/run/php5-fpm.pid'
    default['php']['fpm']['error_log']  = '/var/log/php5-fpm/fpm-master.log'
end

default['php']['fpm']['log_level'] = 'notice'
default['php']['fpm']['emergency_restart_threshold'] = '16'
default['php']['fpm']['emergency_restart_interval'] = '1h'
default['php']['fpm']['process_control_timeout'] = '30s'
default['php']['fpm']['daemonize'] = 'yes'
default['php']['fpm']['events.mechanism'] = 'epoll'

default['app']['php'] = '5.3'
default['app']['pear_channels'] = []
default['app']['pear_packages'] = {}
default['app']['composer'] = true

default['app']['list'] = []
default['app']['root_directory'] = '/vagrant'

default['app']['default_settings']['port'] = "80"
default['app']['default_settings']['chroot'] = false
default['app']['default_settings']['chdir'] = false
default['app']['default_settings']['directory'] = ""
default['app']['default_settings']['socket'] = true
default['app']['default_settings']['use_fpm'] = true
default['app']['default_settings']['fpm'] = {}
default['app']['default_settings']['composer_location'] = 'composer.json'
default['app']['default_settings']['composer_options'] = ''
default['app']['default_settings']['db']['encoding'] = 'utf8'
default['app']['default_settings']['db']['collation'] = 'utf8_general_ci'
default['app']['default_settings']['db']['userhost'] = '%'
default['app']['default_settings']['vhost']['enabled'] = true
default['app']['default_settings']['vhost']['domain'] = nil

default['app']['install_mysql'] = true

include_attribute 'mysql::server'
