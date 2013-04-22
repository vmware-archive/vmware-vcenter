# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vcenter::vmknic{ "${esx1['hostname']}:vmk1":
  ensure => present,  
  transport => Transport['vcenter'],
  hostVirtualNicSpec => {
    ip => {
      dhcp => false,
      ipAddress => '192.168.99.191',
      subnetMask => '255.255.255.0',
    },
    mtu => 9000,
  }
}
