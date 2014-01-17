#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:esx_mem).provider(:esx_mem) do
  esx_mem_yml =  YAML.load_file(my_fixture('esx_mem.yml'))
  esxconfiguremem = esx_mem_yml['esxconfiguremem']

  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']

  let(:esx_configure_mem) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:esx_mem).new(
    :name              => esxconfiguremem['host'],
    :configure_mem     => esxconfiguremem['configure_mem'],
    :storage_groupip   => esxconfiguremem['storage_groupip'],
    :vnics_ipaddress   => esxconfiguremem['vnics_ipaddress'],
    :iscsi_vswitch     => esxconfiguremem['iscsi_vswitch'],
    :iscsi_netmask     => esxconfiguremem['iscsi_netmask'],
    :vnics             => esxconfiguremem['vnics'],
    :iscsi_chapuser    => esxconfiguremem['iscsi_chapuser'],
    :iscsi_chapsecret  => esxconfiguremem['iscsi_chapsecret'],
    :disable_hw_iscsi  => esxconfiguremem['disable_hw_iscsi'],
    :host_username     => esxconfiguremem['host_username'],
    :host_password     => esxconfiguremem['host_password'],
    :script_executable_path    => esxconfiguremem['script_executable_path'],
    :setup_script_filepath     => esxconfiguremem['setup_script_filepath'],
    :transport         => transport,
    :catalog           => @catalog
    )
  end

  esxinstallmem = esx_mem_yml['esxinstallmem']

  let :esx_install_mem do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })

    @catalog.add_resource(transport)

    Puppet::Type.type(:esx_mem).new(
    :name                      => esxinstallmem['host'],
    :install_mem               => esxinstallmem['install_mem'],
    :host_username             => esxinstallmem['host_username'],
    :host_password             => esxinstallmem['host_password'],
    :script_executable_path    => esxinstallmem['script_executable_path'],
    :setup_script_filepath     => esxinstallmem['setup_script_filepath'],
    :transport                 => transport,
    :catalog                   => @catalog
    )
  end

  describe "when configuring mem on esx host" do
    it "should be able to configure mem on esx host" do
      esx_configure_mem.provider.configure_mem='test'
    end
  end

  describe "when installing mem on esx host" do
    it "should be able to install mem on esx host" do
      if (esx_install_mem.provider.install_mem == 'false')
        esx_install_mem.provider.install_mem='test'
      end
    end
  end
end