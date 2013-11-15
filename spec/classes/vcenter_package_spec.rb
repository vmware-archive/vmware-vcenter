require 'spec_helper'

describe 'vcenter::package' do
  context 'puppet enterprise' do
    let(:facts){{
      :puppetversion => 'Puppet Enterprise 3.0.0',
    }}

    it do
      should contain_package('rest-client').
        with_provider('pe_gem')
      should contain_package('net-ssh').
        with_provider('pe_gem')
      should contain_package('hashdiff').with(
        :ensure => '0.0.6',
        :provider => 'pe_gem'
      )
      should contain_package('nori').with(
        :ensure => '1.1.5',
        :provider => 'pe_gem'
      )
      should contain_package('gyoku').with(
        :ensure => '1.0.0z2',
        :provider => 'pe_gem'
      )
      should contain_package('rbvmomi').with(
        :ensure => '1.6.0.z1',
        :provider => 'pe_gem'
      )
    end
  end

  context 'puppet' do
    let(:facts){{
      :puppetversion => '3.2.0',
    }}

    it do
      should contain_package('rest-client').
        with_provider('gem')
      should contain_package('net-ssh').
        with_provider('gem')
      should contain_package('hashdiff').with(
        :ensure => '0.0.6',
        :provider => 'gem'
      )
      should contain_package('nori').with(
        :ensure => '1.1.5',
        :provider => 'gem'
      )
      should contain_package('gyoku').with(
        :ensure => '1.0.0z2',
        :provider => 'gem'
      )
      should contain_package('rbvmomi').with(
        :ensure => '1.6.0.z1',
        :provider => 'gem'
      )
    end
  end
end
