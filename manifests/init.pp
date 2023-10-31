# @summary This sets up a puppetserver on CentOS 8
#
# This module sets up a puppetserver and configures r10k, hiera-eyaml, puppetdb, and puppet client.
#
# @example
#   class { 'puppet_server':
#     r10k_control_repo    => 'git@github.com:devops-jason/controlrepo.git',
#     min_heap_size        => '512m',
#     max_heap_size        => '512m',
#  }
#
# @param r10k_control_repo
#   The git url for the control_repo used by r10k to deploy the modules per environment.
#
# @param min_heap_size
#   Java heap size minimum used by the puppetserver in /etc/sysconfig/puppetserver.
#
# @param max_heap_size
#   Java heap size maximum used by puppetserver in /etc/sysconfig/puppetserver.
#
class puppet_server (
  String $r10k_control_repo,
  String $min_heap_size = '512m',
  String $max_heap_size = '512m'
) {
  package { 'puppet-release':
    ensure   => 'installed',
    source   => 'https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm',
    provider => 'rpm',
  }

  package { 'puppetserver':
    ensure  => 'installed',
    require => Package['puppet-release'],
    notify  => Service['puppetserver'],
  }

  package { 'puppet':
    ensure  => 'installed',
    require => Package['puppet-release'],
    notify  => Service['puppet'],
  }

  package { 'hiera-eyaml':
    ensure   => 'installed',
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
    require => File['/etc/puppetlabs/'],
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/puppet.conf.erb'),
    require => File['/etc/puppetlabs/puppet/'],
    notify  => [Service['puppetserver'], Service['puppet']],
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/puppet_server/hiera.yaml',
    require => File['/etc/puppetlabs/puppet/'],
    notify  => Service['puppetserver'],
  }

  file { '/etc/sysconfig/puppetserver':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_server/sysconfig_puppetserver.erb'),
    require => Package['puppetserver'],
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
    require => File['/etc/puppetlabs/puppet/keys/'],
  }

  file { '/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem':
    ensure  => 'file',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    require => Exec['create eyaml keys'],
  }

  file { '/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem':
    ensure  => 'file',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    require => Exec['create eyaml keys'],
  }

  package { 'git':
    ensure => 'installed',
  }

  exec { 'generate root sshkeys':
    command => '/usr/bin/yes y | /usr/bin/ssh-keygen -t rsa -b 2048 -C "r10k" -f /root/.ssh/id_rsa -q -N "" ',
    creates => '/root/.ssh/id_rsa',
  }

  class { 'r10k':
    remote  => $r10k_control_repo,
    require => Exec['generate root sshkeys'],
  }

  service { 'puppetserver':
    ensure => 'running',
    enable => true,
  }

  service { 'puppet':
    ensure => 'running',
    enable => true,
  }
}
