# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_vswitch { "172.16.103.81:vSwitch5":
  ensure         => present,
  path           => "/datacenter1",
  num_ports      => 1024,
  nics           => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"],
  nicorderpolicy => {
    activenic  => ["vmnic1", "vmnic4"],
    standbynic => ["vmnic3", "vmnic2"]
  }
  ,
  mtu            => 5000,
  checkbeacon    => false,
  transport      => Transport['vcenter'],
}

esx_vswitch { "172.16.103.91:vSwitch5":
  ensure         => present,
  path           => "/datacenter2",
  num_ports      => 1024,
  nics           => ["vmnic1", "vmnic2", "vmnic3", "vmnic4"],
  nicorderpolicy => {
    activenic  => ["vmnic1", "vmnic4"],
    standbynic => ["vmnic3", "vmnic2"]
  }
  ,
  mtu            => 5000,
  checkbeacon    => false,
  transport      => Transport['vcenter'],
}
