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

    contact => {
      contact => '900-555-1212',
      name => 'John Doe',
    },

#   defaultPortConfig => {

#     blocked => {
#       inherited => false,
#       value => false,
#     },

#     inShapingPolicy => {
#       inherited => false,
#       averageBandwidth => {
#         inherited => false,
#         value => 3000,
#       },
#       burstSize => {
#         inherited => false,
#         value => 4500,
#       },
#       enabled => {
#         inherited => false,
#         value => true,
#       },
#       peakBandwidth => {
#         inherited => false,
#         value => 3500,
#       },
#     },


#     networkResourcePoolKey => {
#       inherited => false,
#       value => 'vmotion',
#     },

#     outShapingPolicy => {
#       inherited => false,
#       averageBandwidth => {
#         inherited => false,
#         value => 2999,
#       },
#       burstSize => {
#         inherited => false,
#         value => 4499,
#       },
#       enabled => {
#         inherited => false,
#         value => true,
#       },
#       peakBandwidth => {
#         inherited => false,
#         value => 3499,
#       },
#     },


#     ipfixEnabled => {
#       inherited => false,
#       value => false,
#     },

#     lacpPolicy => {
#       inherited => false,
#       enable => {
#         inherited => false,
#         value => false,
#       },
#       mode => {
#         inherited => false,
#         value => 'active',
#       },
#     },

#     securityPolicy => {
#       inherited => false,
#       allowPromiscuous => {
#         inherited => false,
#         value => true,
#       },
#       forgedTransmits => {
#         inherited => false,
#         value => true,
#       },
#       macChanges => {
#         inherited => false,
#         value => true,
#       },
#     },

#     txUplink => {
#       inherited => false,
#       value => false,
#     },

#     uplinkTeamingPolicy => {
#       inherited => false,
#       failureCriteria => {
#         inherited => false,
#         checkBeacon => {
#           inherited => false,
#           value => ,
#         },
#         checkDuplex => {
#           inherited => false,
#           value => ,
#         },
#         checkErrorPercent => {
#           inherited => false,
#           value => ,
#         },
#         checkSpeed => {
#           inherited => false,
#           value => ,
#         },
#         fullDuplex => {
#           inherited => false,
#           value => ,
#         },
#         percentage => {
#           inherited => false,
#           value => ,
#         },
#         speed => {
#           inherited => false,
#           value => ,
#         },
#       },
#       notifySwitches => {
#         inherited => false,
#         value => ,
#       },
#       policy => {
#         inherited => false,
#         value => ,
#       },
#       reversePolicy => {
#         inherited => false,
#         value => ,
#       },
#       rollingOrder => {
#         inherited => false,
#         value => ,
#       },
#       uplinkPortOrder => {
#         inherited => false,
#         activeUplinkPort => ,
  #         standbyUplinkPort => ,
#       },
#     },

#     vlan => {
#       inherited => false,
#       vsphereType => 'VmwareDistributedVirtualSwitchVlanIdSpec',
#       vlanIdSingle => 43,
#       X vsphereType => 'VmwareDistributedVirtualSwitchPVlanSpec',
#       X pvlanId => 411,
#       vsphereType => 'VmwareDistributedVirtualSwitchTrunkVlanSpec',
#       vlanId => [
#         { start => 3005, end => 3305 },
#         { start => 1001, end => 1300 },
#       ],
#     },

#   },

    defaultProxySwitchMaxNumPorts => 128,

    description => 'test dvswitch',

#   extensionKey => 'extensionKey arbitrary string',

    host => [
      {
        # host => "${esx1['hostname']}",
        host => 'host-31',
        operation => 'add',
        backing => {
          pnicSpec => [
            {pnicDevice => 'vmnic1', uplinkPortgroupKey => 'dvportgroup-39'},
          ],
        },
      },
      {
        # host => "${esx2['hostname']}",
        host => 'host-35',
        operation => 'add',
        backing => {
          pnicSpec => [
            {pnicDevice => 'vmnic1', uplinkPortgroupKey => 'dvportgroup-39'},
          ],
        },
      },
    ],

#   dvswitch_name => 'attempttochange',

    numStandalonePorts => 42,

#   policy => {
#     autoPreInstallAllowed => true,
#     autoUpgradeAllowed => true,
#     partialUpgradeAllowed => false,
#   },

#   switchIpAddress => "8.8.8.8",

#   uplinkPortgroup => ,

    # can't update uplinkPortPolicy before proxy switches exist?
    uplinkPortPolicy => {
      uplinkPortName => ['uplink1', 'uplink2'],
    },

#   vendorSpecificConfig => [
#     { key => 'key1', opaqueData => 'value11' },
#     { key => 'key2', opaqueData => 'value2' },
#   ],

  }

}
