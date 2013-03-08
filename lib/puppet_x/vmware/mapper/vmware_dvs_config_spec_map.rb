# Copyright (C) 2013 VMware, Inc.
module PuppetX::VMware::Mapper

  class VMwareDVSConfigSpecMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'VMwareDVSConfigSpec',
        ],
        :configVersion => LeafData[
          :desc => "Version string of switch to be changed. Required.",
        ],
        :contact => {
          Node => NodeData[
            :node_type => 'DVSContactInfo',
          ],
          :name => LeafData[
            :prop_name => :contact_name,
            :desc => "responsible person's name",
          ],
          :contact => LeafData[
            :prop_name => :contact_info,
            :desc => "responsible person's contact info",
          ],
        },

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
          # vendorSpecificConfig XXX unused?

          # from base class DVSPortSetting
          # vmDirectPathGen2Allowed XXX unused?

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
              :misc => [InheritablePolicyExempt],
            ],
            :inherited => LeafData[
              :misc => [InheritablePolicyInherited],
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :desc => "Is vlan setting inherited? true or false",
              :valid_enum => [:true, :false],
            ],
            # XXX hack - vlanIdSingle - vsphere API name is vlanId
            :vlanIdSingle => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :requires_siblings => [:vsphereType],
              #
              # vlan.vlanId can't be automatically validated or munged
              #
              # 'vlan' may be VmwareDistributedVirtualSwitchVlanIdSpec or
              # VmwareDistributedVirtualSwitchTrunkVlanSpec -- so vlanId 
              # is either an integer or an array of NumericRange objects
              #
              #VmwareDistributedVirtualSwitchVlanIdSpec.vlanid
              # validate => PuppetX::VMware::Mapper::validate_i_ge(0),
              # munge => PuppetX::VMware::Mapper::munge_to_i,
              #VmwareDistributedVirtualSwitchTrunkVlanSpec.vlanid
              # hash => {Puppet::Property::VMware_Array_Hash => {}},
              #
            ],
            :vlanId => LeafData[
              :prop_name => PROP_NAME_IS_FULL_PATH,
              :requires_siblings => [:vsphereType],
              :olio => { 
                Puppet::Property::VMware_Array_Hash => { 
                  :property_option => {
                    :array_matching => :all,
                    :key => :start,
                  },
                  :type => 'NumericRange', 
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

        :defaultProxySwitchMaxNumPorts => LeafData[
          :desc => "The default host proxy switch maximum port number",
          :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
          :munge => PuppetX::VMware::Mapper::munge_to_i,
        ],
        :description => LeafData[
          :desc => "description of the switch",
        ],
        :extensionKey => LeafData[
          :desc => "The key of the extension registered by a remote server "\
                   "that controls the switch",
        ],

=begin

        :host => {
        },

# Mapper can't yet handle array of objects, let alone 
# an array of nested objects including arrays of objects

DistributedVirtualSwitchHostMemberConfigSpec[] host
> mo_ref host
> xsd:int maxProxySwitchPorts OPTIONAL
> xsd:string operation ENUM[add,edit,remove]
> DistributedVirtualSwitch[HostMember]PnicBacking backing OPTIONAL
> > DistributedVirtualSwitchHostMemberPnicSpec[] pnicSpec 
> > > xsd:int connectionCookie
> > > xsd:string pnicDevice
> > > xsd:string uplinkPortgroupKey
> > > xsd:string uplinkPortKey

host => {
  host => "esx1.my.local",
  maxProxyPorts => 240,
  operation => "add",
  backing => {
    pnicSpec0 => {
      pnicDevice = "en0",
      uplinkPortgroupKey => "dvUplink",
    },
    pnicSpec1 => {
      pnicDevice = "en1",
      uplinkPortgroupKey => "dvUplink",
    },
  },
}

=end

=begin
        # The 'host' property fails to handle an array as it should
        # for the reason discussed above. Instead, the 'host' property:
        # -- handles only a single host, not an arrray
        # -- handles only a limited number of pnics, not an array
        # -- requires pnicSpec 'array' specified as pnicSpec0, pnicSpec1, ...
        :host => {
          Node => NodeData[
            :node_type => 'DistributedVirtualSwitchHostMemberConfigSpec',
          ],
          :backing => {
            Node => NodeData[
              :node_type => "DistributedVirtualSwitchHostMemberBacking",
            ],
            :pnicSpec => {
              :pnicSpec0 => {
                :connectionCookie => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Cookie. See "\
                    "http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.dvs.HostMember.PnicSpec.html",
                ],
                :pnicDevice => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 
                    "Name of the physical NIC to be added to the proxy switch",
                ],
                :uplinkPortgroupKey => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 
                    "Key of the portgroup to be connected to the physical NIC",
                ],
                :uplinkPortKey => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 
                    "Key of the port to be connected to the physical NIC",
                ],
              },
              :pnicSpec1 => {
                :connectionCookie => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => "Cookie. See "\
                    "http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.dvs.HostMember.PnicSpec.html",
                ],
                :pnicDevice => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 
                    "Name of the physical NIC to be added to the proxy switch",
                ],
                :uplinkPortgroupKey => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 
                    "Key of the portgroup to be connected to the physical NIC",
                ],
                :uplinkPortKey => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 
                    "Key of the port to be connected to the physical NIC",
                ],
              },
            },
          },
          :host => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Identifies host member of the DVS",
          ],
          :maxProxySwitchPorts => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Maximum number of ports in the HostProxySwitch",
            :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
            :munge => PuppetX::VMware::Mapper::munge_to_i,
          ],
          :operation => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Host member operation. One of add, edit, or remove",
            :valid_enum => [
              :add,
              :edit,
              :remove,
            ],
          ],
        },
=end

        #maxPorts - deprecated
        :name => LeafData[
          :prop_name => :dvswitch_name,
          :desc => "name of the switch",
        ],
        :numStandalonePorts => LeafData[
          :desc => "The The number of standalone ports in the switch. "\
                   "Standalone ports are ports that do not belong to any portgroup.",
          :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
          :munge => PuppetX::VMware::Mapper::munge_to_i,
        ],
        :policy => {
          Node => NodeData[
            :node_type => 'DVSPolicy',
          ],
          :autoPreInstallAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Switch usage policy. see "\
              "http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.DistributedVirtualSwitch.SwitchPolicy.html",
            :valid_enum => [:true, :false],
            :requires_siblings => [:autoUpgradeAllowed, :partialUpgradeAllowed],
          ],
          :autoUpgradeAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Switch usage policy. see "\
              "http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.DistributedVirtualSwitch.SwitchPolicy.html",
            :valid_enum => [:true, :false],
            :requires_siblings => [:autoPreInstallAllowed, :partialUpgradeAllowed],
          ],
          :partialUpgradeAllowed => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Switch usage policy. see "\
              "http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.DistributedVirtualSwitch.SwitchPolicy.html",
            :valid_enum => [:true, :false],
            :requires_siblings => [:autoPreInstallAllowed, :autoUpgradeAllowed],
          ],
        },
        :switchIpAddress => LeafData[
          :desc => "IP address for the switch, specified using IPv4 dot "\
              "notation. The utility of this address is defined by other switch features."
        ],
        :uplinkPortgroup => LeafData[
          :desc => "The uplink portgroups",
          :olio => {Puppet::Property::VMware_Array => {}},
        ],
        :uplinkPortPolicy => {
          Node => NodeData[
            :node_type => 'DVSNameArrayUplinkPortPolicy',
          ],
          :uplinkPortName => LeafData[
            :desc => "Array of uniform names of uplink ports on each host. "\
                     "The size of the array indicates the number of uplink ports "\
                     "that will be created for each host in the switch.",
            :misc => [Puppet::Property::VMware_Array],
          ],
        },
        :vendorSpecificConfig => LeafData[
          :olio => { 
            Puppet::Property::VMware_Array_Hash => { 
              :property_option => {
                :array_matching => :all,
                :key => :key,
              },
              :type => 'DistributedVirtualSwitchKeyedOpaqueBlob', 
            },
          },
        ],


      }

      super
    end
  end
end
