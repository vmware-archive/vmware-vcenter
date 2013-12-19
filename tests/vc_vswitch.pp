# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vswitch { 'name':
  name      => "vSwitch5",
  ensure    => present,
  host      => "172.16.103.95",
  path      => "/ghetto-vdc/",
  num_ports => 4,
  nics      => ["vmnic1", "vmnic2"],
  transport => Transport['vcenter'],
}