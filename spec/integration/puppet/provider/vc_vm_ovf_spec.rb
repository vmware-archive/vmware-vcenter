#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:vc_vm_ovf).provider(:vc_vm_ovf) do
  vc_vm_ovf_yml =  YAML.load_file(my_fixture('vc_vm_ovf.yml'))
  importovf = vc_vm_ovf_yml['importovf']

  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']

  let(:import_ovf) do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:vc_vm_ovf).new(
    :name               => importovf['vmname'],
    :ensure             => importovf['ensure'],
    :transport          => transport,
    :catalog            => @catalog,
    :host             => importovf['host'],
    :datacenter         => importovf['datacenter'],
    :ovffilepath => importovf['ovffilepath'],
    :target_datastore         => importovf['target_datastore'],
    :disk_format  => importovf['disk_format']
    )
  end

  exportovf = vc_vm_ovf_yml['exportovf']

  let :export_ovf do
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })

    @catalog.add_resource(transport)

    Puppet::Type.type(:vc_vm_ovf).new(
    :name               => exportovf['vmname'],
    :ensure             => exportovf['ensure'],
    :transport          => transport,
    :catalog            => @catalog,
    :host             => exportovf['host'],
    :datacenter         => exportovf['datacenter'],
    :ovffilepath => exportovf['ovffilepath'],
    :target_datastore         => exportovf['target_datastore'],
    :disk_format  => exportovf['disk_format']
    )
  end

  describe "when importing an ovf" do
    it "should be able to import ovf" do
      expect {  import_ovf.provider.create}.to_not raise_error      
    end
  end

  describe "when exporting  an vm  - which already exists" do
    it "should be able to export vm" do
      expect { export_ovf.provider.destroy}.to_not raise_error       
    end
  end
end