#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:vc_vm_register).provider(:vc_vm_register) do  
  integration_yml =  File.join(provider_path, '/fixtures/integration/integration.yml')
  vc_vm_register_yml = YAML.load_file(integration_yml) 
  registervm = vc_vm_register_yml['registervm']  
  
  transport_yml =  File.join(provider_path, '/fixtures/integration/transport.yml')
  transport_yml = YAML.load_file(transport_yml)
  transport_node = transport_yml['transport']  

  let(:register_vm) do
    @catalog = Puppet::Resource::Catalog.new
      transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options => transport_node['options'],
     })
    @catalog.add_resource(transport)

  Puppet::Type.type(:vc_vm_register).new(
      :name               => registervm['name'],
    :ensure             => registervm['ensure'],
    :transport          => transport, 
    :catalog            => @catalog,
    :hostip             => registervm['hostip'],
    :datacenter         => registervm['datacenter'],  
    :vmpath_ondatastore => registervm['vmpath_ondatastore'],
    :astemplate         => registervm['astemplate']
    )
  end  

  removevm = vc_vm_register_yml['removevm']
  
  let :remove_vm do
    @catalog = Puppet::Resource::Catalog.new
      transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
     })

    @catalog.add_resource(transport)

  Puppet::Type.type(:vc_vm_register).new(
      :name               => removevm['name'],
    :ensure             => removevm['ensure'],
    :transport          => transport, 
    :catalog            => @catalog,
    :hostip             => removevm['hostip'],
    :datacenter         => removevm['datacenter']
    )
  end

  describe "when registering a vm" do     
    it "should be able to register vm" do
      register_vm.provider.create
    end
  end

  describe "when removing a vm - which already exists" do
    it "should be able to remove vm" do
      remove_vm.provider.destroy
    end
  end
end