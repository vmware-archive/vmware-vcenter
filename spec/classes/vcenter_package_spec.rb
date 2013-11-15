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
        :version => '0.0.6',
        :provider => 'pe_gem'
      )
      should contain_package 'nori'
      should contain_package 'gyoku'
      should contain_package 'rbvmomi'
    end
  end
end
