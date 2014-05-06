# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => "${vcenter['username']}",
  password => "${vcenter['password']}",
  server   => "${vcenter['server']}",
  options  => $vcenter['options'],
}

vc_datacenter { "${dc1['path']}":
  ensure    => present,
  path      => "${dc1['path']}",
  transport => Transport['vcenter'],
}

vcenter::dvswitch{ "${dc1['path']}/dvs1:create":
  ensure    => present,
  transport => Transport['vcenter'],
  spec      => {},
} ->

vcenter::dvswitch{ "${dc1['path']}/dvs1:configure":
  ensure    => present,
  transport => Transport['vcenter'],
  spec      => {
    defaultPortConfig => {
      lacpPolicy => {
        inherited => false,
        enable    => {
          inherited => false,
          value     => true,
        },
        mode      => {
          inherited => false,
          value     => 'passive',
        },
      },
    },
    uplinkPortPolicy => {
      uplinkPortName => ['uplink1', 'uplink2'],
    },
  }
} ->

vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg-esx":
  ensure    => present,
  transport => Transport['vcenter'],
  spec      => {
    type              => 'earlyBinding',
    autoExpand        => true,
    numPorts          => 8,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchVlanIdSpec => {
          inherited => false,
          vlanId    => 1,
        },
      },
      uplinkTeamingPolicy => {
        inherited => false,
        policy    => {
          inherited => false,
          value     => 'loadbalance_ip',
        },
      },
    },
    policy => {
      blockOverrideAllowed               => true,
      ipfixOverrideAllowed               => false,
      livePortMovingAllowed              => false,
      networkResourcePoolOverrideAllowed => false,
      portConfigResetAtDisconnect        => true,
      securityPolicyOverrideAllowed      => false,
      shapingOverrideAllowed             => false,
      uplinkTeamingOverrideAllowed       => false,
      vendorConfigOverrideAllowed        => false,
      vlanOverrideAllowed                => false,
    },
  }
} ->

vcenter::dvswitch{ "${dc1['path']}/dvs1:add_host":
  ensure    => present,
  transport => Transport['vcenter'],
  spec      => {
    host => [{
      host      => "${esx1['hostname']}",
      operation => 'add'
    }],
  }
} ->

vc_dvswitch_migrate{ "${esx1['hostname']}:${dc1['path']}/dvs1":
  vmk0      => 'dvpg-esx',
  vmnic0    => 'dvs1-uplink-pg',
  vmnic1    => 'dvs1-uplink-pg',
  transport => Transport['vcenter'],
}
