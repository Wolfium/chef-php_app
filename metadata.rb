name             'php_app'
maintainer       'Ivan Chepurnyi'
maintainer_email 'ivan@ecomdev.org'
license          'All rights reserved'
description      'Installs/Configures php application'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'

depends "apt"
depends "nginx"
depends "php"
depends "composer"
depends "build-essential"
depends "mysql", ">= 4.1.2"
depends "database"
