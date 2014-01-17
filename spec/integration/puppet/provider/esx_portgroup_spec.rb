#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

describe Puppet::Type.type(:esx_portgroup).provider(:esx_portgroup) do
puts "We are printing value #{described_class.inspect}"

let :portgroup do
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


Puppet::Type.type(:esx_portgroup).new(
  :name => '172.28.7.3:test01',  
  :portgrouptype => 'VMkernel',
  :failback => 'true',
  :mtu => '2014',
  :overridefailback => 'enabled',
  :overridefailoverorder => 'disabled',
  :nicorderpolicy => '{
    activenic  => ["vmnic5"],
    standbynic => ["vmnic4"]
  }',
  :overridecheckbeacon => 'enabled',
  :checkbeacon    => true,
  :vmotion => 'enabled',
  :ipsettings => 'dhcp',
  :ipaddress => '172.28.7.3',
  :subnetmask => '255.255.255.0',
  :traffic_shaping_policy => 'enabled',
  :averagebandwidth => '2000',
  :peakbandwidth => '2000',
  :burstsize => '2024',
  :vswitch => 'vSwitch1',  
  :path => '/AS1000DC/DDCCluster/',
  :vlanid => '1023',
  :transport => transport,
  :catalog => catalog,  
  )
  
end

describe "When managing the portgroup" do
  it "should create portgroup" do
    portgroup.provider.create 
    if (portgroup.provider.exists? == true)
      puts "Successfully added the port group"
    else
      fail "Failed to add the port group"
    end
  end
  it "should remove portgroup" do
    portgroup.provider.destroy
    if (portgroup.provider.exists? == false)
      puts "successfully removed the port group"
    else
      fail "Failed to remove the port group"
    end
  end 
end
end
