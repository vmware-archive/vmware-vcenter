#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'

provider_path = Pathname.new(__FILE__).parent.parent.parent.parent

describe Puppet::Type.type(:esx_portgroup).provider(:esx_portgroup) do

let :portgroup do

transport_yaml = File.join(provider_path, '/fixtures/integration/transport.yml')
integration_yaml = File.join(provider_path, '/fixtures/integration/integration.yml')

transport_yaml = YAML.load_file(transport_yaml)
transport_node = transport_yaml['transport']
  
portgroup_path_yaml = YAML.load_file(integration_yaml)
portgroup_node = portgroup_path_yaml['esx_portgroup']

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
  :name => portgroup_node['name'],  
  :portgrouptype => portgroup_node['portgrouptype'],
  :failback => portgroup_node['failback'],
  :mtu => portgroup_node['mtu'],
  :overridefailback => portgroup_node['overridefailback'],
  :overridefailoverorder => portgroup_node['overridefailoverorder'],
  :nicorderpolicy => portgroup_node['nicorderpolicy'],
  :overridecheckbeacon => portgroup_node['overridecheckbeacon'],
  :checkbeacon    => portgroup_node['checkbeacon'],
  :vmotion => portgroup_node['vmotion'],
  :ipsettings => portgroup_node['ipsettings'],
  :ipaddress => portgroup_node['ipaddress'],
  :subnetmask => portgroup_node['subnetmask'],
  :traffic_shaping_policy => portgroup_node['traffic_shaping_policy'],
  :averagebandwidth => portgroup_node['averagebandwidth'],
  :peakbandwidth => portgroup_node['peakbandwidth'],
  :burstsize => portgroup_node['burstsize'],
  :vswitch => portgroup_node['vswitch'],  
  :path => portgroup_node['path'],
  :vlanid => portgroup_node['vlanid'],
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
