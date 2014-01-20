#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:vm_vnic).provider(:vm_vnic) do

let :vnic do
transport_yaml = YAML.load_file(my_fixture('transport.yml'))
transport_node = transport_yaml['transport']

catalog = Puppet::Resource::Catalog.new
transport = Puppet::Type.type(:transport).new({
  :name => transport_node['name'],
  :username => transport_node['username'],
  :password => transport_node['password'],
  :server => transport_node['server'],
  :options => transport_node['options'],
})
catalog.add_resource(transport)


Puppet::Type.type(:vm_vnic).new(
  :name => 'Network adapter 1',  
  :vm_name => 'ASM7.5_ASHISH',
  :portgroup => 'Customer PXE 18',
  :nic_type => 'E1000',
  :datacenter => '/AS1000DC',
  :transport => transport,
  :catalog => catalog,  
  )
  
end

describe "When managing the vnic" do
  it "should create vnic" do
    vnic.provider.create    
    if (vnic.provider.exists? != nil)
      puts "Successfully added the vnic"
    else
      fail "Failed to add the vnic"
    end
  end
  it "should remove vnic" do
    vnic.provider.destroy
    sleep 10
    if (vnic.provider.exists? == nil)
      puts "successfully removed the vnic"
    else
      fail "Failed to remove the vnic"
    end
  end 
end
end
