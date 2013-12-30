# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_vswitch { 'name':
  name           => "vSwitch5",
  ensure         => present,
  host           => "172.16.103.581",
  path           => "/DDCDC/",
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
