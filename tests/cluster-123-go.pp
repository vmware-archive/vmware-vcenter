# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => "${vcenter['username']}",
  password => "${vcenter['password']}",
  server   => "${vcenter['server']}",
  options  => $vcenter['options'],
}

transport { 'esx1':
  username => $esx1['username'],
  password => $esx1['password'],
  server   => $esx1['address_esx'],
  options  => $vcenter['options'],
}
transport { 'esx2':
  username => $esx2['username'],
  password => $esx2['password'],
  server   => $esx2['address_esx'],
  options  => $vcenter['options'],
}
transport { 'esx3':
  username => $esx3['username'],
  password => $esx3['password'],
  server   => $esx3['address_esx'],
  options  => $vcenter['options'],
}

$ensure_mm = present
esx_maintmode { "${esx1['hostname']}:X":
  ensure                    => $ensure_mm,
  timeout                   => 0,
  transport                 => Transport['esx1'],
} ~>
esx_maintmode { "${esx2['hostname']}:X":
  ensure                    => $ensure_mm,
  timeout                   => 0,
  transport                 => Transport['esx2'],
} ~>
esx_maintmode { "${esx3['hostname']}:X":
  ensure                    => $ensure_mm,
  timeout                   => 0,
  transport                 => Transport['esx3'],
}

vc_datacenter { "${dc1['path']}":
  path      => "${dc1['path']}",
  ensure    => present,
  transport => Transport['vcenter'],
}

vcenter::cluster { "${cluster1['path']}":
  ensure    => present,
  transport => Transport['vcenter'],
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType =>  'ClusterFailoverLevelAdmissionControlPolicy',
        failoverLevel => 1,
      },
      hostMonitoring => enabled,
      vmMonitoring  => 'vmMonitoringDisabled',
    },
  },
}
vc_cluster_drs { "${cluster1['path']}":
  enabled => true,
  enable_vm_behavior_overrides => true,
  default_vm_behavior => 'fullyAutomated',
  vmotion_rate => 1,
  transport => Transport['vcenter'],
  #
  require => Vc_cluster["${cluster1['path']}"],
  before => Anchor["${cluster1['path']}"],
}

vcenter::host { [
    "${esx1['hostname']}",
    "${esx2['hostname']}",
    "${esx3['hostname']}",
  ]:
  path      => "${cluster1['path']}",
  username  => "${esx_shared_username}",
  password  => "${esx_shared_password}",

  shells => {
    esxi_shell_time_out             => 0,
    esxi_shell_interactive_time_out => 0,
    suppress_shell_warning          => 1,
    ssh => {
      running => true,
      policy => 'automatic',
    },
  },

  transport => Transport['vcenter'],
  before => Anchor['hostsAdded'],
}
anchor{ 'hostsAdded':
}

vcenter::dvswitch{ "${dc1['path']}/dvs1:create":
  ensure => present,
  transport => Transport['vcenter'],
}

vcenter::dvswitch{ "${dc1['path']}/dvs1":
  ensure => present,
  transport => Transport['vcenter'],

  networkResourceManagementEnabled => true,   # aka 'NIOC Enabled'

  spec => {
    maxMtu => 9000,

    host => [

      {
        host => "${esx1['hostname']}",
        operation => 'add',
        backing => {
          pnicSpec => [
            {
              pnicDevice => 'vmnic2',
              uplinkPortgroupKey => 'dvs1-uplink-pg',
            },
            {
              pnicDevice => 'vmnic3',
              uplinkPortgroupKey => 'dvs1-uplink-pg',
            },
          ],
        },
      },

      {
        host => "${esx2['hostname']}",
        operation => 'add',
        backing => {
          pnicSpec => [
            {
              pnicDevice => 'vmnic2',
              uplinkPortgroupKey => 'dvs1-uplink-pg',
            },
            {
              pnicDevice => 'vmnic3',
              uplinkPortgroupKey => 'dvs1-uplink-pg',
            },
          ],
        },
      },

      {
        host => "${esx3['hostname']}",
        operation => 'add',
        backing => {
          pnicSpec => [
            {
              pnicDevice => 'vmnic2',
              uplinkPortgroupKey => 'dvs1-uplink-pg',
            },
            {
              pnicDevice => 'vmnic3',
              uplinkPortgroupKey => 'dvs1-uplink-pg',
            },
          ],
        },
      },

    ],

    uplinkPortPolicy => {
      uplinkPortName => ['uplink1', 'uplink2'],
    },
  },
  require => Anchor['hostsAdded'],
}

##

vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg-esx":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    type => 'earlyBinding',
    autoExpand => true,
    numPorts => 8,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchVlanIdSpec => {
          inherited => false,
          vlanId => 201,
        },
      },
      uplinkTeamingPolicy => {
        inherited => false,
        value => 'loadbalance_ip',
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
  },
  before => Anchor['networkComplete'],
}

vcenter::vmknic{ "${esx1['hostname']}:vmk0":
  ensure => present,  
  transport => Transport['vcenter'],
  hostVirtualNicSpec => {
    distributedVirtualPort => {
      switchUuid => 'dvs1',
      portgroupKey => 'dvpg-esx',
    },
    ip => {
      dhcp => false,
      ipAddress  => "${esx1['address_esx']}",
      subnetMask => "${esx1['netmask_esx']}",
    },
  },
  require => Vcenter::Dvportgroup["${dc1['path']}/dvs1:dvpg-esx"],
  before => Anchor['networkComplete'],
} ~>
vcenter::vmknic{ "${esx2['hostname']}:vmk0":
  ensure => present,  
  transport => Transport['vcenter'],
  hostVirtualNicSpec => {
    distributedVirtualPort => {
      switchUuid => 'dvs1',
      portgroupKey => 'dvpg-esx',
    },
    ip => {
      dhcp => false,
      ipAddress =>  "${esx2['address_esx']}",
      subnetMask => "${esx2['netmask_esx']}",
    },
  },
  require => Vcenter::Dvportgroup["${dc1['path']}/dvs1:dvpg-esx"],
  before => Anchor['networkComplete'],
} ~>
vcenter::vmknic{ "${esx3['hostname']}:vmk0":
  ensure => present,  
  transport => Transport['vcenter'],
  hostVirtualNicSpec => {
    distributedVirtualPort => {
      switchUuid => 'dvs1',
      portgroupKey => 'dvpg-esx',
    },
    ip => {
      dhcp => false,
      ipAddress =>  "${esx3['address_esx']}",
      subnetMask => "${esx3['netmask_esx']}",
    },
  },
  require => Vcenter::Dvportgroup["${dc1['path']}/dvs1:dvpg-esx"],
  before => Anchor['networkComplete'],
}

vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg-vms":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    type => 'earlyBinding',
    autoExpand => true,
    numPorts => 128,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchVlanIdSpec => {
          inherited => false,
          vlanId => 107,
        },
      },
      uplinkTeamingPolicy => {
        inherited => false,
        value => 'loadbalance_ip',
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
  },
  before => Anchor['networkComplete'],
}

vcenter::dvportgroup{ "${dc1['path']}/dvs1:dvpg-fix":
  ensure => present,
  transport => Transport['vcenter'],
  spec => {
    type => 'earlyBinding',
    autoExpand => false,
    numPorts => 128,
    defaultPortConfig => {
      vlan => {
        typeVmwareDistributedVirtualSwitchVlanIdSpec => {
          inherited => false,
          vlanId => 105,
        },
      },
      uplinkTeamingPolicy => {
        inherited => false,
        value => 'loadbalance_ip',
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
  },
  before => Anchor['networkComplete'],
}

anchor{ 'networkComplete':
  before => Anchor['clusterComplete'],
}

esx_datastore { [
      "${esx1['hostname']}:${nfs_datastore1['name']}",
      "${esx2['hostname']}:${nfs_datastore1['name']}",
      "${esx3['hostname']}:${nfs_datastore1['name']}",
    ]:
  ensure      => present,
  type        => 'nfs',
  remote_host => "${nfs_datastore1['remote_host']}",
  remote_path => "${nfs_datastore1['remote_path']}",
  transport   => Transport['vcenter'],
  require => Anchor['networkComplete'],
  before  => Anchor['storageComplete'],
}
esx_datastore { [
      "${esx1['hostname']}:${nfs_datastore2['name']}",
      "${esx2['hostname']}:${nfs_datastore2['name']}",
      "${esx3['hostname']}:${nfs_datastore2['name']}",
    ]:
  ensure      => present,
  type        => 'nfs',
  remote_host => "${nfs_datastore2['remote_host']}",
  remote_path => "${nfs_datastore2['remote_path']}",
  transport   => Transport['vcenter'],
  require => Anchor['networkComplete'],
  before  => Anchor['storageComplete'],
}
anchor{ 'storageComplete':
  before => Anchor['clusterComplete'],
}

esx_syslog { [
    "${esx1['hostname']}",
    "${esx2['hostname']}",
    "${esx3['hostname']}",
  ]:
  log_dir_unique => true,
  transport      => Transport['vcenter'],
  log_host       => "${log_host}",
  require => Anchor['storageComplete'],
  before  => Anchor['clusterComplete'],
}

anchor { 'clusterComplete':
}

esx_maintmode { [
      "${esx1['hostname']}:complete",
      "${esx2['hostname']}:complete",
      "${esx3['hostname']}:complete",
    ]:
  ensure    => absent,
  transport => Transport['vcenter'],
  require   => Anchor['clusterComplete'],
}
