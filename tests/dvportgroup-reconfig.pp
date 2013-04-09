# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => "${vcenter['username']}",
  password => "${vcenter['password']}",
  server   => "${vcenter['server']}",
  options  => $vcenter['options'],
}

vc_datacenter { "${dc1['path']}":
  path      => "${dc1['path']}",
  ensure    => present,
  transport => Transport['vcenter'],
}

vcenter::dvswitch{ "${dc1['path']}/dvs1":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    maxMtu => 9000,
    linkDiscoveryProtocolConfig => {
      operation => 'none',
      protocol => 'lldp',
    },
  }
}
vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg1":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    type => 'earlyBinding',
    autoExpand => false,
    numPorts => 128,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchTrunkVlanSpec => {
          inherited => false,
          vlanId => [
            {start => 4092, end => 4092},
            {start =>    0, end => 4080},
          ],
        },
      },
    },
  },
}

vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg2":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    type => 'earlyBinding',
    autoExpand => true,
    numPorts => 16,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchVlanIdSpec => {
          inherited => false,
          vlanId => 0,
        },
      },
    },
    portNameFormat => '<dvsName>.<portgroupName>.<portIndex>',
  },
}
