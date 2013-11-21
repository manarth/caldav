# -*- mode: ruby -*-
# vi: set ft=ruby :

###
# Caldav-manager specific configuration
###
node caldavmgr_template {

  # Load apache2 meta-package.
  package {'apache2': }

  # Add PHP5.
  package {'php5': }
  package {'php5-cli': }
  package {'php5-mysql': }
  # package {'php5-sqlite': }

  package {'libapache2-mod-php5':}

  # Add MySQL server
  package {'mysql-server': } 


  # Create database "caldav".
  exec {'mysql-create-caldav-db':
    command => "mysql -e 'CREATE DATABASE caldav;'",
    require => Package['mysql-server'],
    unless => "mysql caldav -e 'SELECT 1=1'",
  }

  # Add the account that baikal caldav will use to access the DB.
  exec { 'mysql-add-caldav-user':
    command => "mysql -e 'GRANT ALL ON caldav.* to \"caldav\"@\"localhost\" IDENTIFIED BY \"caldav_password\";'",
    require => [
      Package['mysql-server'],
      Exec['mysql-create-caldav-db'],
    ],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    # Validate that there is a 'caldav' user who can access the 'caldav' database.
    unless => "mysql -u caldav --password='caldav_password' caldav -e 'SELECT 1=1'",
  }

  # Push the blank DB.
  # Note that this contains /just/ the DB structure, no data.
  exec { 'mysql-populate-db':
    command => "mysql caldav < /vagrant/db/caldav_initial.sql",
    require => [
      Package['mysql-server'],
      Exec['mysql-create-caldav-db'],
    ],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    # Only push the blank DB if there is no current database.
    # Validate whether the 'users' table exists in the caldav database.
    unless => "mysql caldav -e 'SELECT COUNT(*) FROM users'",
  }


  # Set up /var/www/caldav.example.com, and link to the application
  file {'/var/www/caldav.example.com':
    target => '/vagrant/baikal/',
  }



  # Symlink the application's VHOST file to sites-enabled.
  file {'/etc/apache2/sites-available/baikal.conf':
    target => '/var/www/caldav.example.com/Specific/virtualhosts/baikal.apache2',
    require => [Package['apache2'], File['/var/www/caldav.example.com'],],
  }
  file {'/etc/apache2/sites-enabled/baikal.conf':
    target => '/etc/apache2/sites-available/baikal.conf',
    require => File['/etc/apache2/sites-available/baikal.conf'],
    notify => Service['apache2'],
  }
  file {'/etc/apache2/sites-enabled/000-default':
    ensure => 'absent',
    require => Package['apache2'],
    notify => Service['apache2'],
  }

  service {'apache2':
    require => Package['apache2'],
    ensure => 'running',
  }
}
