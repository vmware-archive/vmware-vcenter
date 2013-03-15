# Copyright (C) 2013 VMware, Inc.
# Manage vcenter vmware distributed virtual switch
define vcenter::dvswitch (
  $ensure,
  $spec = {},
  # transport is a metaparameter
) {

# Sample input template for this defined type
# Consult the vSphere API documentation for syntax and semantics:
# http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/vim.DistributedVirtualSwitch.html
# For general reference information see:
# http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.pg.doc/PG_Preface.html
# http://pubs.vmware.com/vsphere-51/topic/com.vmware.wssdk.apiref.doc/right-pane.html

# sample # spec => {
# sample #   configVersion => ,
# sample #   contact => {
# sample #     contact => ,
# sample #     name => ,
# sample #   },
# sample #   defaultPortConfig => {
# sample #     blocked => {
# sample #       inherited => ,
# sample #       value => ,
# sample #     },
# sample #     inShapingPolicy => {
# sample #       inherited => ,
# sample #       averageBandwidth => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       burstSize => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       enabled => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       peakBandwidth => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #     },
# sample #     ipfixEnabled => {
# sample #       inherited => ,
# sample #       value => ,
# sample #     },
# sample #     lacpPolicy => {
# sample #       inherited => ,
# sample #       enable => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       mode => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #     },
# sample #     networkResourcePoolKey => {
# sample #       inherited => ,
# sample #       value => ,
# sample #     },
# sample #     outShapingPolicy => {
# sample #       inherited => ,
# sample #       averageBandwidth => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       burstSize => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       enabled => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       peakBandwidth => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #     },
# sample #     securityPolicy => {
# sample #       inherited => ,
# sample #       allowPromiscuous => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       forgedTransmits => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       macChanges => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #     },
# sample #     txUplink => {
# sample #       inherited => ,
# sample #       value => ,
# sample #     },
# sample #     uplinkTeamingPolicy => {
# sample #       inherited => ,
# sample #       failureCriteria => {
# sample #         inherited => ,
# sample #         checkBeacon => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #         checkDuplex => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #         checkErrorPercent => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #         checkSpeed => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #         fullDuplex => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #         percentage => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #         speed => {
# sample #           inherited => ,
# sample #           value => ,
# sample #         },
# sample #       },
# sample #       notifySwitches => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       policy => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       reversePolicy => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       rollingOrder => {
# sample #         inherited => ,
# sample #         value => ,
# sample #       },
# sample #       uplinkPortOrder => {
# sample #         inherited => ,
# sample #         activeUplinkPort => ,
# sample #         standbyUplinkPort => ,
# sample #       },
# sample #     },
# sample #     vlan => {
# sample #       inherited => ,
# sample #       pvlanId => ,
# sample #       vlanId => ,
# sample #       vsphereType => ,
# sample #     },
# sample #   },
# sample #   defaultProxySwitchMaxNumPorts => ,
# sample #   description => ,
# sample #   host => {
# sample #     backing => {
# sample #       pnicSpec => {
# sample #         pnicDevice => ,
# sample #         uplinkPortgroupKey => ,
# sample #         uplinkPortKey => ,
# sample #       },
# sample #     },
# sample #     host => ,
# sample #     maxProxySwitchPorts => ,
# sample #     operation => [add | edit | remove],
# sample #   },
# sample #   linkDiscoveryProtocolConfig => {
# sample #     operation => ,
# sample #     protocol => ,
# sample #   },
# sample #   maxMtu =>
# sample #   extensionKey => ,
# sample #   name => ,
# sample #   numStandalonePorts => ,
# sample #   policy => {
# sample #     autoPreInstallAllowed => ,
# sample #     autoUpgradeAllowed => ,
# sample #     partialUpgradeAllowed => ,
# sample #   },
# sample #   switchIpAddress => ,
# sample #   uplinkPortgroup => ,
# sample #   uplinkPortPolicy => {
# sample #     uplinkPortName => ,
# sample #   },
# sample # }

  $path = $name

  vc_dvswitch { $path:
    ensure    => $ensure,
    transport => $transport,
    config_version                           => nested_value($spec, ['configVersion']),
    contact_info                             => nested_value($spec, ['contact', 'contact']),
    contact_name                             => nested_value($spec, ['contact', 'name']),
    default_proxy_switch_max_num_ports       => nested_value($spec, ['defaultProxySwitchMaxNumPorts']),
    description                              => nested_value($spec, ['description']),
    dvswitch_name                            => nested_value($spec, ['name']),
    extension_key                            => nested_value($spec, ['extensionKey']),
    host                                     => nested_value($spec, ['host']),
    link_discovery_protocol_config_operation => nested_value($spec, ['linkDiscoveryProtocolConfig', 'operation']),
    link_discovery_protocol_config_protocol  => nested_value($spec, ['linkDiscoveryProtocolConfig', 'protocol']),
    max_mtu                                  => nested_value($spec, ['maxMtu']),
    num_standalone_ports                     => nested_value($spec, ['numStandalonePorts']),
    policy_auto_pre_install_allowed          => nested_value($spec, ['policy', 'autoPreInstallAllowed']),
    policy_auto_upgrade_allowed              => nested_value($spec, ['policy', 'autoUpgradeAllowed']),
    policy_partial_upgrade_allowed           => nested_value($spec, ['policy', 'partialUpgradeAllowed']),
    switch_ip_address                        => nested_value($spec, ['switchIpAddress']),
    uplink_portgroup                         => nested_value($spec, ['uplinkPortgroup']),
    uplink_port_name                         => nested_value($spec, ['uplinkPortPolicy', 'uplinkPortName']),
    vendor_specific_config                   => nested_value($spec, ['vendorSpecificConfig']),

    default_port_config_blocked_inherited => nested_value($spec, ['defaultPortConfig', 'blocked', 'inherited']),
    default_port_config_blocked_value     => nested_value($spec, ['defaultPortConfig', 'blocked', 'value']),

    default_port_config_in_shaping_policy_inherited                   => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'inherited']),
    default_port_config_in_shaping_policy_average_bandwidth_inherited => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'averageBandwidth', 'inherited']),
    default_port_config_in_shaping_policy_average_bandwidth_value     => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'averageBandwidth', 'value']),
    default_port_config_in_shaping_policy_burst_size_inherited        => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'burstSize', 'inherited']),
    default_port_config_in_shaping_policy_burst_size_value            => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'burstSize', 'value']),
    default_port_config_in_shaping_policy_enabled_inherited           => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'enabled', 'inherited']),
    default_port_config_in_shaping_policy_enabled_value               => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'enabled', 'value']),
    default_port_config_in_shaping_policy_peak_bandwidth_inherited    => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'peakBandwidth', 'inherited']),
    default_port_config_in_shaping_policy_peak_bandwidth_value        => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'peakBandwidth', 'value']),

    default_port_config_ipfix_enabled_inherited => nested_value($spec, ['defaultPortConfig', 'ipfixEnabled', 'inherited']),
    default_port_config_ipfix_enabled_value     => nested_value($spec, ['defaultPortConfig', 'ipfixEnabled', 'value']),

    default_port_config_lacp_policy_inherited        => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'inherited']),
    default_port_config_lacp_policy_enable_inherited => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'enable', 'inherited']),
    default_port_config_lacp_policy_enable_value     => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'enable', 'value']),
    default_port_config_lacp_policy_mode_inherited   => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'mode', 'inherited']),
    default_port_config_lacp_policy_mode_value       => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'mode', 'value']),

    default_port_config_network_resource_pool_key_inherited => nested_value($spec, ['defaultPortConfig', 'networkResourcePoolKey', 'inherited']),
    default_port_config_network_resource_pool_key_value     => nested_value($spec, ['defaultPortConfig', 'networkResourcePoolKey', 'value']),

    default_port_config_out_shaping_policy_average_bandwidth_inherited => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'averageBandwidth', 'inherited']),
    default_port_config_out_shaping_policy_average_bandwidth_value     => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'averageBandwidth', 'value']),
    default_port_config_out_shaping_policy_burst_size_inherited        => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'burstSize', 'inherited']),
    default_port_config_out_shaping_policy_burst_size_value            => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'burstSize', 'value']),
    default_port_config_out_shaping_policy_enabled_inherited           => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'enabled', 'inherited']),
    default_port_config_out_shaping_policy_enabled_value               => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'enabled', 'value']),
    default_port_config_out_shaping_policy_inherited                   => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'inherited']),
    default_port_config_out_shaping_policy_peak_bandwidth_inherited    => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'peakBandwidth', 'inherited']),
    default_port_config_out_shaping_policy_peak_bandwidth_value        => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'peakBandwidth', 'value']),

    default_port_config_security_policy_inherited                   => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'inherited']),
    default_port_config_security_policy_allow_promiscuous_inherited => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'allowPromiscuous', 'inherited']),
    default_port_config_security_policy_allow_promiscuous_value     => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'allowPromiscuous', 'value']),
    default_port_config_security_policy_forged_transmits_inherited  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'forgedTransmits', 'inherited']),
    default_port_config_security_policy_forged_transmits_value      => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'forgedTransmits', 'value']),
    default_port_config_security_policy_mac_changes_inherited       => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'macChanges', 'inherited']),
    default_port_config_security_policy_mac_changes_value           => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'macChanges', 'value']),

    default_port_config_tx_uplink_inherited => nested_value($spec, ['defaultPortConfig', 'txUplink', 'inherited']),
    default_port_config_tx_uplink_value     => nested_value($spec, ['defaultPortConfig', 'txUplink', 'value']),

    default_port_config_uplink_teaming_policy_failure_criteria_inherited                     => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_beacon_inherited        => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkBeacon', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_beacon_value            => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkBeacon', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_duplex_inherited        => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkDuplex', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_duplex_value            => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkDuplex', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_error_percent_inherited => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkErrorPercent', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_error_percent_value     => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkErrorPercent', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_speed_inherited         => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkSpeed', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_speed_value             => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkSpeed', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_full_duplex_inherited         => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'fullDuplex', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_full_duplex_value             => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'fullDuplex', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_percentage_inherited          => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'percentage', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_percentage_value              => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'percentage', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_speed_inherited               => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'speed', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_speed_value                   => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'speed', 'value']),

    default_port_config_uplink_teaming_policy_inherited                 => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'inherited']),
    default_port_config_uplink_teaming_policy_notify_switches_inherited => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'notifySwitches', 'inherited']),
    default_port_config_uplink_teaming_policy_notify_switches_value     => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'notifySwitches', 'value']),
    default_port_config_uplink_teaming_policy_policy_inherited          => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'policy', 'inherited']),
    default_port_config_uplink_teaming_policy_policy_value              => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'policy', 'value']),
    default_port_config_uplink_teaming_policy_reverse_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'reversePolicy', 'inherited']),
    default_port_config_uplink_teaming_policy_reverse_policy_value      => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'reversePolicy', 'value']),
    default_port_config_uplink_teaming_policy_rolling_order_inherited   => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'rollingOrder', 'inherited']),
    default_port_config_uplink_teaming_policy_rolling_order_value       => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'rollingOrder', 'value']),

    default_port_config_uplink_teaming_policy_uplink_port_order_inherited           => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'uplinkPortOrder', 'inherited']),
    default_port_config_uplink_teaming_policy_uplink_port_order_active_uplink_port  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'uplinkPortOrder', 'activeUplinkPort']),
    default_port_config_uplink_teaming_policy_uplink_port_order_standby_uplink_port => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'uplinkPortOrder', 'standbyUplinkPort']),

    default_port_config_vlan_inherited    => nested_value($spec, ['defaultPortConfig', 'vlan', 'inherited']),
    default_port_config_vlan_vsphere_type => nested_value($spec, ['defaultPortConfig', 'vlan', 'vsphereType']),
    default_port_config_vlan_pvlan_id     => nested_value($spec, ['defaultPortConfig', 'vlan', 'pvlanId']),
    default_port_config_vlan_vlan_id      => nested_value($spec, ['defaultPortConfig', 'vlan', 'vlanId']),
  }
}
