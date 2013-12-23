# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
vc_portgroup { 'name':
  name => "test25",
  ensure => present,
  type => "VMkernel",
  vmotion => "true",
  ipconfig => "manual",
  ipaddress => "172.10.11.16",
  subnetmask => "255.255.0.0",
  traffic_shaping_policy => "Enabled",
  averagebandwidth => 1000,
  peakbandwidth => 1000,
  burstsize => 1024,
  vswitchname => vSwitch1,
  host => "172.16.103.95",
  path => "/Datacenter/cluster-1/",
  vlanid => 4095,
  transport => Transport['vcenter'],
}
