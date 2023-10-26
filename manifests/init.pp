# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include puppet_server
class puppet_server {

  exec { 'add puppet-release':
    command => 'dnf install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm',
    unless => 'dnf list | grep puppet-release 2> /dev/null',
  }

  file { '/etc/puppetlabs/':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/puppetlabs/puppet/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/puppetlabs/']
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/puppet.conf.erb')
    require => [ Exec['add puppet-release'], File['/etc/puppetlabs/puppet'] ],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/puppet_server/hiera.yaml'
    require => File['/etc/puppetlabs/puppet/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/puppetlabs/'],
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/puppetlabs/puppetserver/'],
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/puppetserver.conf.erb'),
    require => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/auth.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/auth.conf.erb'),
    require => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/ca.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/ca.conf.erb'),
    require => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver']
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/global.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/global.conf.erb'),
    requie  => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/metrics.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/metrics.conf.erb'),
    require => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetservver/conf.d/web-routes.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/web-routes.conf.erb'),
    require => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/conf.d/webserver.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/webserver.conf.erb'),
    require => File['/etc/puppetlabs/puppetserver/conf.d/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/request-logging.xml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/puppet_server/request-logging.xml',
    require => File['/etc/puppetlabs/puppetserver/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppetserver/logback.xml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/puppet_server/logback.xml',
    require => File['/etc/puppetlabs/puppetserver/'],
    notify  => Service['puppetserver'],
  }

}
