actions :create, :delete

default_action :create

attribute :name, :kind_of => String, :name_attribute => true # Name of the fpm app
attribute :user, :kind_of => String, :required => true # User for php process
attribute :group, :kind_of => String, :required => true # Group for php process
attribute :listen, :kind_of => String, :default => '127.0.0.1:9000' # Listen value for FPM process
attribute :listen_params, :kind_of => Hash, :default => {} # Listen value for FPM process
attribute :prefix, :kind_of => [String, NilClass], :default => nil # Prefix for php process files
attribute :pm, :kind_of => String, :equal_to => %w(dynamic static), :default => 'dynamic' # Type of process manager
attribute :max_children, :kind_of => Fixnum, default: 6
attribute :start_servers, :kind_of => Fixnum, default: 4
attribute :min_spare_servers, :kind_of => Fixnum, default: 3
attribute :max_spare_servers, :kind_of => Fixnum, default: 5
attribute :max_requests, :kind_of => Fixnum, default: 500
attribute :status_path, :kind_of => [String, NilClass], default: '/status'
attribute :ping_path, :kind_of => [String, NilClass], default: '/ping'
attribute :ping_response, :kind_of => String, default: 'pong'
attribute :request_terminate_timeout, :kind_of => [String, NilClass], default: nil
attribute :request_slowlog_timeout, :kind_of => [String, NilClass], default: '5s'
attribute :slowlog, :kind_of => [String, NilClass], default: '/var/log/$pool.log.slow'
attribute :rlimit_files, :kind_of => [Fixnum, NilClass], default: 4096
attribute :rlimit_core, :kind_of => [Fixnum, String, NilClass], default: 0
attribute :chroot, :kind_of => [String, NilClass], default: nil
attribute :chdir, :kind_of => [String, NilClass], default: nil
attribute :catch_workers_output, :kind_of => [String], :equal_to => %w(yes no), default: 'no'
attribute :env, :kind_of => [String, NilClass]
attribute :php_value, :kind_of => [String, NilClass]
attribute :php_flag, :kind_of => [String, NilClass]
attribute :php_admin_value, :kind_of => [String, NilClass]
attribute :php_admin_flag, :kind_of => [String, NilClass]
# How soon should we restart php-fpm.
attribute :reload, :kind_of => Symbol, :equal_to => [:delayed, :immediately], :default => :delayed

def initialize(*args)
  super
  @action = :create
end