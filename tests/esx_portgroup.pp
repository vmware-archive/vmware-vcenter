# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_portgroup { 'name':
  name => "testVM",
  ensure => present,
  type => "VMkernel",
  vmotion => "Disabled",
  ipsettings => "static",
  ipaddress => "172.16.12.16",
  subnetmask => "255.255.0.0",
  traffic_shaping_policy => "Disabled",
  averagebandwidth => 1000,
  peakbandwidth => 1000,
  burstsize => 1024,
  vswitch => vSwitch1,
  host => "172.16.100.56",
  path => "/Datacenter/cluster-1/",
  vlanid => 5,
  transport => Transport['vcenter'],
}
