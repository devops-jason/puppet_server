# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          'min_heap_size'        => '512m',
          'max_heap_size'        => '512m',
          'r10k_control_repo'    => 'git@github.com:devops-jason/controlrepo.git'
        }
      end

      it do
        is_expected.to contain_package('puppet-release')

        is_expected.to contain_package('puppetserver').with(
          {
            'ensure'  => 'installed',
            'require' => 'Package[puppet-release]',
            'notify'  => 'Service[puppetserver]'
          },
        )

        is_expected.to contain_package('puppet').with(
          {
            'ensure'  => 'installed',
            'require' => 'Package[puppet-release]',
            'notify'  =>  'Service[puppet]'
          },
        )

        is_expected.to contain_package('hiera-eyaml').with(
          {
            'ensure'   => 'installed',
            'require'  => 'Package[puppetserver]',
            'provider' => 'puppet_gem'
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/').with(
          {
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => 'Package[puppetserver]'
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/puppet/').with(
          {
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => 'File[/etc/puppetlabs/]'
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with(
          {
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'File[/etc/puppetlabs/puppet/]',
            'notify'  => ['Service[puppetserver]', 'Service[puppet]']
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/puppet/hiera.yaml').with(
          {
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'source'  => 'puppet:///modules/puppet_server/hiera.yaml',
            'require' => 'File[/etc/puppetlabs/puppet/]',
            'notify'  => 'Service[puppetserver]'
          },
        )

        is_expected.to contain_file('/etc/sysconfig/puppetserver').with(
          {
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'Package[puppetserver]',
            'notify'  => 'Service[puppetserver]'
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/puppet/keys/').with(
          {
            'ensure'  => 'directory',
            'owner'   => 'puppet',
            'group'   => 'puppet',
            'mode'    => '0500',
            'require' => 'File[/etc/puppetlabs/puppet/]'
          },
        )

        is_expected.to contain_exec('create eyaml keys').with(
          {
            'creates'  => '/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem',
            'require'  => 'File[/etc/puppetlabs/puppet/keys/]'
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem').with(
          {
            'ensure'  => 'file',
            'owner'   => 'puppet',
            'group'   => 'puppet',
            'mode'    => '0400',
            'require' => 'Exec[create eyaml keys]'
          },
        )

        is_expected.to contain_file('/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem').with(
          {
            'ensure'  => 'file',
            'owner'   => 'puppet',
            'group'   => 'puppet',
            'mode'    => '0400',
            'require' => 'Exec[create eyaml keys]'
          },
        )

        is_expected.to contain_package('git').with(
          {
            'ensure' => 'installed'
          },
        )

        is_expected.to contain_exec('generate root sshkeys').with(
          {
            'command' => '/usr/bin/yes y | /usr/bin/ssh-keygen -t rsa -b 2048 -C "r10k" -f /root/.ssh/id_rsa -q -N "" ',
            'creates' => '/root/.ssh/id_rsa'
          },
        )

        is_expected.to contain_class('r10k')
        is_expected.to contain_service('puppetserver')
        is_expected.to contain_service('puppet')
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
