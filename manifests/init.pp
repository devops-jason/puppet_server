# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include puppet_server
class puppet_server ( String $min_heap_size = '512m', String $max_heap_size = '512m' )
{
  exec { 'add puppet-release':
    command => 'dnf install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm',
    unless => 'dnf list | grep puppet-release 2> /dev/null',
  }

  package { 'puppetserver':
    ensure  => 'present',
    require => Exec['add puppet-release',
    notify  => Service['puppetsever']],
  }

  package { 'hiera-eyaml':
    ensure   => 'present',
    require  => Package['puppetserver'],
    provider => 'puppet_gem',
  }

  file { '/etc/puppetlabs/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['puppetserver'],
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
    content => template('puppet_server/puppet.conf.erb'),
    require => [ Exec['add puppet-release'], File['/etc/puppetlabs/puppet'] ],
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/puppet_server/hiera.yaml',
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

  file { '/etc/sysconfig/puppetserver':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/sysconfig_puppetserver.erb'),
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/keys/':
    ensure  => 'directory',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0500',
    require => File['/etc/puppetlabs/puppet/'],
  }

  exec { 'create eyaml keys':
    command => '/opt/puppetlabs/puppet/bin/eyaml createkeys\
    --pkcs7-private-key=/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem\
    --pkcs7-public-key=/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem',
    creates => '/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem',
    require => File['/etc/puppetlabs/puppet/keys/']
  }

  file { '/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem':
    ensure  => 'present',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    require => Exec['create eyaml keys'],
  }

  file { '/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem':
    ensure  => 'present',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    require => Exec['create eyaml keys'],
  }

  package { 'git':
    ensure => 'present',
  }

  sshkey { 'github.com':
    ensure  => 'present',
    type    => 'ssh-rsa',
    target  => '/root/.ssh/known_hosts',
    type    => 'ecdsa-sha2-nistp256',
    key     => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlz\
    dHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg='
    require => Package['git']
  }

  ssh_authoried_key { 'jasonmiller@macbook-air.local':
    ensure => 'present',
    user   => 'root',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCnGRMg34lBwgtVt3xUclvX7mClOwp3O08y3y2hoz\
    LKxDtNaWlby7Die4w2pl4DwnlcRghFK+/G0y0DNH7LoYXV/acaSuz2ONE/W1/g1Hvp4l1ZISMDDa3dBLhL\
    kxgbL0vJYjMIF0Md41LaTcXP3pE/MMTm89SpniGqmwPIaRyL5zTMcVN7Ti+lf+nUdQmj2+sAdprz+cOOjl1\
    gmoD+vuz71ngkWVGtyBwA1YXHnVrHdnEzqibteFtb1RIY4koLEam0Xlm+RvAfuCglZnvmSIjs3tVs+bca76B\
    /+RFUQKml7cOMo3VQjQvrF/pE8IDpM4BcpRzmZeA2aJx7XIH6Gx/F'
  }

  exec { 'generate root sshkeys':
    command => 'yes y | ssh-keygen -t rsa -b 2048 -C "r10k" -f /root/.ssh/id_rsa -q -N "" ',
    creates => '/root/.ssh/id_rsa',
  }

  class { 'r10k':
    remote  => 'git@github.com:devops-jason/controlrepo.git',
    require => Exec['generate root sshkeys'],
  }

  cron { 'r10k deploy modules to production':
    command => '/usr/bin/r10k deploy environment --modules production',
    user    => 'root',
    minute  => '*/5',
    require => Class['r10k'],
  }

}
