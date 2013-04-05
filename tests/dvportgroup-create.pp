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
  spec => {}
}
vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg1":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    type => 'earlyBinding',
    autoExpand => false,
    numPorts => 128,
    numStandalonePorts => 12,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchVlanIdSpec => {
          inherited => false,
          vlanId => 17,
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
    numStandalonePorts => 8,
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
