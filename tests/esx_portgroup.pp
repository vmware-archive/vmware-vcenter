# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_portgroup { 'name':
  name => "172.16.100.56:test05",
  ensure => present,
  portgrouptype => "VMkernel",
  overridefailback => "enabled",
  failback => "false",
  mtu => "2019",
  overridefailoverorder => "enabled",
  nicorderpolicy => {
	standbynic => ["vmnic1"]
  },
  overridecheckbeacon => "enabled",
  checkbeacon    => "true",
  vmotion => "enabled",
  ipsettings => "static",
  ipaddress => "172.16.104.52",
  subnetmask => "255.255.255.0",
  traffic_shaping_policy => "enabled",
  averagebandwidth => 5000,
  peakbandwidth => 7027,
  burstsize => 2085,
  vswitch => vSwitch1,
  path => "/Datacenter/Cluster01/",
  vlanid => 1,
  transport => Transport['vcenter'],
}
