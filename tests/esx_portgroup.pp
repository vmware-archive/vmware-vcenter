# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_portgroup { 'name':
  name => "test01",
  ensure => present,
  type => "VMkernel",
  failback => "Yes",
  mtu => "2014",
  overridefailoverorder => "Enabled",
  nicorderpolicy => {
    activenic  => ["vmnic1"],
    standbynic => []
  },
  checkbeacon    => true,
  vmotion => "Enabled",
  ipsettings => "static",
  ipaddress => "172.16.103.76",
  subnetmask => "255.255.255.0",
  traffic_shaping_policy => "Enabled",
  averagebandwidth => 2000,
  peakbandwidth => 2000,
  burstsize => 2024,
  vswitch => vSwitch1,
  host => "172.16.100.56",
  path => "/Datacenter/cluster-1/",
  vlanid => 1023,
  transport => Transport['vcenter'],
}
