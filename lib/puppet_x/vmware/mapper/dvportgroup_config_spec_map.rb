# Copyright (C) 2013 VMware, Inc.
module PuppetX::VMware::Mapper

  class DVPortgroupConfigSpecMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'DVPortgroupConfigSpec',
        ],

        :autoExpand => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
          :valid_enum => [:true, :false],

        ],
        :configVersion => LeafData[
          :desc => "Version string of switch to be changed. Required.",
        ],

        :defaultPortConfig => {
          Node => NodeData[
            :node_type => 'VMwareDVSPortSetting',
          ],

          # from base class DVSPortSetting
          :blocked => {
            Node => NodeData[
              :node_type => 'BoolPolicy',
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :value => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is port blocked? true or false",
              :valid_enum => [:true, :false],
            ],
          },

          # from base class DVSPortSetting
          :inShapingPolicy => {
            Node => NodeData[
              :node_type => 'DVSTrafficShapingPolicy',
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :averageBandwidth => {
              Node => NodeData[
                :node_type => 'LongPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_in_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "averageBandwidth in bits per second",
                :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
            },
            :burstSize => {
              Node => NodeData[
                :node_type => 'LongPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_in_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "maximum burstSize allowed in bytes",
                :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
            },
            :enabled => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_in_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is traffic shaper enabled on this port? "\
                    "true or false",
                :valid_enum => [:true, :false],
              ],
            },
            :peakBandwidth => {
              Node => NodeData[
                :node_type => 'LongPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_in_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "peak bandwidth during bursts in bits per second",
                :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
            },
          },
          # from base class DVSPortSetting

          :networkResourcePoolKey => {
            Node => NodeData[
              :node_type => 'StringPolicy',
            ],
            :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :value => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "networkResourcePoolKey to be associated "\
                "with the port. String. Default is '-1', indicating "\
                "no associated resource pool."
            ],
          },

          # from base class DVSPortSetting

          :outShapingPolicy => {
            Node => NodeData[
              :node_type => 'DVSTrafficShapingPolicy',
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :averageBandwidth => {
              Node => NodeData[
                :node_type => 'LongPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_out_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "averageBandwidth in bits per second",
                :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
            },
            :burstSize => {
              Node => NodeData[
                :node_type => 'LongPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_out_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "maximum burstSize allowed in bytes",
                :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
            },
            :enabled => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_out_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is traffic shaper enabled on this port? "\
                    "true or false",
                :valid_enum => [:true, :false],
              ],
            },
            :peakBandwidth => {
              Node => NodeData[
                :node_type => 'LongPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_out_shaping_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "peak bandwidth during bursts in bits per second",
                :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
            },
          },

          # from base class DVSPortSetting
          # vendorSpecificConfig XXX unused

          # from base class DVSPortSetting
          # vmDirectPathGen2Allowed XXX unused

          # from extended class VMwareDVSPortSetting
          :ipfixEnabled => {
            Node => NodeData[
              :node_type => 'BoolPolicy',
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :value => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is ipfix monitoring enabled on this port? "\
                  "true or false",
              :valid_enum => [:true, :false],
            ],
          },

=begin lacpPolicy is not applicable in port default settings context
=end
          # from extended class VMwareDVSPortSetting
          :lacpPolicy => {
            Node => NodeData[
              :node_type => 'VMwareUplinkLacpPolicy',
            ],
            :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :enable => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_lacp_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is lacp policy enabled on this port? true or false",
                :valid_enum => [:true, :false],
              ],
            },
            :mode => {
              Node => NodeData[
                :node_type => 'StringPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_lacp_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "lacpPolicy mode: active or passive",
                :valid_enum => [ #XXX check allowed values with MOB??? ROB???
                  :active,
                  :passive,
                ],
              ],
            },
          },

          # from extended class VMwareDVSPortSetting
          # qosTag XXX deprecated

          # from extended class VMwareDVSPortSetting
          :securityPolicy => {
            Node => NodeData[
              :node_type => 'DVSSecurityPolicy',
            ],
            :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is security policy inherited? true or false",
                :valid_enum => [:true, :false],
            ],
            :allowPromiscuous => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_security_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is promiscuous reception allowed on this port? "\
                    "true or false",
                :valid_enum => [:true, :false],
              ],
            },
            :forgedTransmits => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_security_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Are forged transmits allowed on this port? "\
                    "true or false",
                :valid_enum => [:true, :false],
              ],
            },
            :macChanges => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_security_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Are MAC address changes allowed on this port? "\
                    "true or false",
                :valid_enum => [:true, :false],
              ],
            },
          },

          # from extended class VMwareDVSPortSetting
          :txUplink => {
            Node => NodeData[
              :node_type => 'BoolPolicy',
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            :value => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "If true, a copy of packets sent to the switch "\
                  "will always be forwarded to an uplink in addition to the "\
                  "regular packet forwarded done by the switch. true or false",
              :valid_enum => [:true, :false],
            ],
          },

          # from extended class VMwareDVSPortSetting
          :uplinkTeamingPolicy => {
            Node => NodeData[
              :node_type => 'VmwareUplinkPortTeamingPolicy',
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is uplink teaming policy inherited? true or false",
              :valid_enum => [:true, :false],
            ],

            :failureCriteria => {
              Node => NodeData[
                :node_type => 'DVSFailureCriteria',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_uplink_teaming_policy_inherited,
                ],
              ],
              :checkBeacon => {
                Node => NodeData[
                  :node_type => 'BoolPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                  :requires => [
                    :default_port_config_uplink_teaming_policy_failure_criteria_inherited,
                  ],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is beacon probing "\
                      "a failure criterion on this port? true or false",
                  :valid_enum => [:true, :false],
                ],
              },
              :checkDuplex => {
                Node => NodeData[
                  :node_type => 'BoolPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is full duplex check "\
                      "a failure criterion on this port? true or false",
                  :valid_enum => [:true, :false],
                ],
              },
              :checkErrorPercent => {
                Node => NodeData[
                  :node_type => 'BoolPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is link error percentage "\
                      "a failure criterion on this port? true or false",
                  :valid_enum => [:true, :false],
                ],
              },
              :checkSpeed => {
                Node => NodeData[
                  :node_type => 'StringPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is link speed "\
                      "a failure criterion on this port? "\
                      "'' (empty string) means speed is not used; "\
                      "'minimum' means given speed is a minimum value; "\
                      "'exact' means given speed is the exact required value.",
                  :valid_enum => [
                    :exact,
                    :minimum,
                    "",
                  ],
                ],
              },
              :fullDuplex => {
                Node => NodeData[
                  :node_type => 'BoolPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "See 'checkDuplex'",
                  :valid_enum => [:true, :false],
                ],
              },
              :percentage => {
                Node => NodeData[
                  :node_type => 'IntPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "If 'checkErrorPercent' is true, this value "\
                      "is the maximum tolerated error percentage.",
                  :validate => PuppetX::VMware::Mapper::validate_i_in(0..100),
                  :munge => PuppetX::VMware::Mapper::munge_to_i,
                ],
              },
              :speed => {
                Node => NodeData[
                  :node_type => 'IntPolicy',
                ],
                :inherited => LeafData[
                  :misc => [InheritablePolicyInherited],
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Is setting inherited? true or false",
                  :valid_enum => [:true, :false],
                ],
                :value => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Exact or minimum speed in megabits per second "\
                      "used as failure criterion. See 'checkSpeed'",
                  :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
                  :munge => PuppetX::VMware::Mapper::munge_to_i,
                ],
              },
            },

            :notifySwitches => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_uplink_teaming_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Flag to specify whether or not to notify the "\
                    "physical switch if a link fails. If this property is "\
                    "true, ESX Server will respond to the failure by "\
                    "sending a RARP packet from a different physical "\
                    "adapter, causing the switch to update its cache.",
                :valid_enum => [:true, :false],
              ],
            },

            :policy => {
              Node => NodeData[
                :node_type => 'StringPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_uplink_teaming_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Network adapter teaming policy. The policy "\
                    "defines the way traffic from the clients of the team "\
                    "is routed through the different uplinks in the team. "\
                    "The policies supported on the VDS platform are listed "\
                    "in DistributedVirtualSwitchNicTeamingPolicyMode.",
=begin
                :desc_link => {
                  :link => "DistributedVirtualSwitchNicTeamingPolicyMode",
                  :url => "http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.DistributedVirtualSwitch.NicTeamingPolicyMode.html",
                },
=end
                :valid_enum => [
                  # DistributedVirtualSwitchNicTeamingPolicyMode
                  :failover_explicit,
                  :loadbalance_ip,
                  :loadbalance_loadbased,
                  :loadbalance_srcid,
                  :loadbalance_srcmac,
                ],
              ],
            },

            :reversePolicy => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_uplink_teaming_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "The flag to indicate whether or not the teaming "\
                    "policy is applied to inbound frames as well. For "\
                    "example, if the policy is explicit failover, a "\
                    "broadcast request goes through uplink1 and comes back "\
                    "through uplink2. Then if the reverse policy is set, "\
                    "the frame is dropped when it is received from uplink2. "\
                    "This reverse policy is useful to prevent the virtual "\
                    "machine from getting reflections. ",
                :valid_enum => [:true, :false],
              ],
            },

            :rollingOrder => {
              Node => NodeData[
                :node_type => 'BoolPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_uplink_teaming_policy_inherited,
                ],
              ],
              :value => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "The flag to indicate whether or not to use a "\
                  "rolling policy when restoring links. For example, assume "\
                  "the explicit link order is (vmnic9, vmnic0), therefore "\
                  "vmnic9 goes down, vmnic0 comes up. However, when vmnic9 "\
                  "comes backup, if rollingOrder is set to be true, vmnic0 "\
                  "continues to be used, otherwise, vmnic9 is restored as "\
                  "specified in the explicit order.",
                :valid_enum => [:true, :false],
              ],
            },

            :uplinkPortOrder => {
              Node => NodeData[
                :node_type => 'VMwareUplinkPortOrderPolicy',
              ],
              :inherited => LeafData[
                :misc => [InheritablePolicyInherited],
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "Is setting inherited? true or false",
                :valid_enum => [:true, :false],
                :requires => [
                  :default_port_config_uplink_teaming_policy_inherited,
                ],
              ],
              :activeUplinkPort => LeafData[
                :olio => {Puppet::Property::VMware_Array => {}},
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "List of active uplink ports (for load balancing)",
              ],
              :standbyUplinkPort => LeafData[
                :olio => {Puppet::Property::VMware_Array => {}},
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => "List of standby uplink ports (for failover)",
              ],
            },

          },

          # from extended class VMwareDVSPortSetting
          :vlan => {
            Node => NodeData[
              :node_type => :ABSTRACT
            ],
            :vsphereType => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :valid_enum => [
                :VmwareDistributedVirtualSwitchVlanIdSpec,
                :VmwareDistributedVirtualSwitchTrunkVlanSpec,
                :VmwareDistributedVirtualSwitchPvlanSpec,
              ],
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is vlan setting inherited? true or false",
              :valid_enum => [:true, :false],
              :requires_siblings => [:vsphereType],
            ],
            #
            # vlan.vlanId can't be automatically validated or munged
            #
            # 'vlan' may be VmwareDistributedVirtualSwitchVlanIdSpec or
            # VmwareDistributedVirtualSwitchTrunkVlanSpec -- so vlanId 
            # is either an integer or an array of NumericRange objects
            #
            # until abstract types are 'improved' in Node, only 
            # one of these properties can be active at a time.
            #
            # XXX hack - vlanIdSingle - vsphere API name is vlanId
            :vlanId => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :requires_siblings => [:vsphereType],
              :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
              :munge => PuppetX::VMware::Mapper::munge_to_i,
            ],
            # XXX hack - vlanIdRanges - vsphere API name is vlanId
            :vlanIdRanges => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :requires_siblings => [:vsphereType],
              :olio => { 
                Puppet::Property::VMware_Array_VIM_Object => { 
                  :property_option => {
                    :type => 'NumericRange',
                    :array_matching => :all,
                    :comparison_scope => :array,
                    :sort_array => true,
                    :key => [:start, :end],
                  },
                },
              },
            ],
            :pvlanId => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :munge => PuppetX::VMware::Mapper::munge_to_i,
              :validate => PuppetX::VMware::Mapper::validate_i_in(1..4094),
              :requires_siblings => [:vsphereType],
            ],
          },
        },

        :description => LeafData[
          :desc => "description of the switch",
        ],
        :name => LeafData[
          :prop_name => :dvportgroup_name,
          :desc => "name of the portgroup",
        ],
        :numPorts => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
          :desc => "number of ports in the portgroup",
          :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
          :munge => PuppetX::VMware::Mapper::munge_to_i,
        ],


        :policy => {
          Node => NodeData[
            :node_type => 'VMwareDVSPortgroupPolicy',
          ],
          # DVPortgroupPolicy
          :blockOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :livePortMovingAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :networkResourcePoolOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :portConfigResetAtDisconnect => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :shapingOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :vendorConfigOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          # VMwareDVSPortgroupPolicy - additional properties
          :ipfixOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :securityPolicyOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :uplinkTeamingOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
          :vlanOverrideAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :valid_enum => [:true, :false],
          ],
        },

        :portNameFormat => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
          :desc => "http://pubs.vmware.com/vsphere-51/topic/"\
                   "com.vmware.wssdk.apiref.doc/"\
                   "vim.dvs.DistributedVirtualPortgroup.ConfigInfo.html#portNameFormat",
        ],
        #scope - unimplemented
        :type => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
          :desc => "http://pubs.vmware.com/vsphere-51/topic/"\
                   "com.vmware.wssdk.apiref.doc/"\
                   "vim.dvs.DistributedVirtualPortgroup.PortgroupType.html",
          :valid_enum => [
            :earlyBinding,
            :ephemeral,
            :lateBinding,
          ],
        ],
        #vendorSpecificConfig - unimplemented

      }

      super
    end
  end
end
