actions :create, :delete, :enable, :disable

default_action :create

attribute :name, :kind_of => String, :name_attribute => true # Main domain
attribute :enabled, :kind_of => [TrueClass, FalseClass], :default => true # Custom include into vhost config of nginx
attribute :custom_include, :kind_of => [String, NilClass], :default => nil # Include additional file into vhost
attribute :port, :kind_of => [String, Array], :default => '80' # Listen port
attribute :directory, :kind_of => String, :required => true
attribute :ssl, :kind_of => [Hash, NilClass], :default => nil # Ssl configuration options
attribute :domains, :kind_of => Array, :default => [] # List of domain names for system
attribute :domain, :kind_of => String, :required => true # Main domain
attribute :deny_paths, :kind_of => Array, :default => [] # List of paths that are denied for public access
attribute :custom_locations, :kind_of => Hash, :default => {} # List of custom locations
attribute :status_path, :kind_of => [String, NilClass], :default => 'status|ping' # Custom status path
attribute :status_ip, :kind_of => Array, :default => [] # Status IP address
attribute :fastcgi_pass, :kind_of => [String, NilClass], :default => nil # fastcgi_pass value for php-fpm
attribute :fastcgi_params, :kind_of => Hash, :default => {} # custom directives for fpm-process
attribute :fastcgi_custom_directives, :kind_of => Hash, :default => {} # custom directives for fpm-process
attribute :front_handler, :kind_of => [TrueClass, FalseClass], :default => true # flag for using of front handler for all pathes
attribute :phpunit, :kind_of => [Hash, NilClass], :default => nil # flag that indicates usage of phpunit on the project

def initialize(*args)
  super
  @action = :create
end