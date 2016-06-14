# Copyright (C) 2013 VMware, Inc.
# Manage vcenter vmware distributed virtual portgroup
define vcenter::dvportgroup (
  # $title is a metaparameter
  $ensure,
  $spec = {},
  # $transport is a metaparameter
) {

  # title format: 
  # dvswitch_path:portgroup_name
  # example:
  # /datacenter5/dvs1:pg-storage
  # /datacenter5/dvs1:pg-vmotion
  $title_array = split($title, ":")
  $dvswitch_path    = $title_array[0]
  $dvportgroup_name = $title_array[1]

  vc_dvportgroup{ $title:

    # 'name' is a reserved property in puppet so
    # vsphere property 'name' is 'dvportgroup_name'
    dvportgroup_name     => $dvportgroup_name,
    ensure               => $ensure,
    transport            => $transport,
   
    # provider will set spec.configVersion automatically
    #onfig_version       => nested_value($spec, ['configVersion']),

    auto_expand          => nested_value($spec, ['autoExpand']),
    description          => nested_value($spec, ['description']),
    num_ports            => nested_value($spec, ['numPorts']),
    port_name_format     => nested_value($spec, ['portNameFormat']),
    type                 => nested_value($spec, ['type']),

    policy_block_override_allowed                 => nested_value($spec, ['policy', 'blockOverrideAllowed']),
    policy_ipfix_override_allowed                 => nested_value($spec, ['policy', 'ipfixOverrideAllowed']),
    policy_live_port_moving_allowed               => nested_value($spec, ['policy', 'livePortMovingAllowed']),
    policy_network_resource_pool_override_allowed => nested_value($spec, ['policy', 'networkResourcePoolOverrideAllowed']),
    policy_port_config_reset_at_disconnect        => nested_value($spec, ['policy', 'portConfigResetAtDisconnect']),
    policy_security_policy_override_allowed       => nested_value($spec, ['policy', 'securityPolicyOverrideAllowed']),
    policy_shaping_override_allowed               => nested_value($spec, ['policy', 'shapingOverrideAllowed']),
    policy_uplink_teaming_override_allowed        => nested_value($spec, ['policy', 'uplinkTeamingOverrideAllowed']),
    policy_vendor_config_override_allowed         => nested_value($spec, ['policy', 'vendorConfigOverrideAllowed']),
    policy_vlan_override_allowed                  => nested_value($spec, ['policy', 'vlanOverrideAllowed']),

    default_port_config_blocked_inherited  => nested_value($spec, ['defaultPortConfig', 'blocked', 'inherited']),
    default_port_config_blocked_value  => nested_value($spec, ['defaultPortConfig', 'blocked', 'value']),
    default_port_config_in_shaping_policy_average_bandwidth_inherited  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'averageBandwidth', 'inherited']),
    default_port_config_in_shaping_policy_average_bandwidth_value  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'averageBandwidth', 'value']),
    default_port_config_in_shaping_policy_burst_size_inherited  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'burstSize', 'inherited']),
    default_port_config_in_shaping_policy_burst_size_value  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'burstSize', 'value']),
    default_port_config_in_shaping_policy_enabled_inherited  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'enabled', 'inherited']),
    default_port_config_in_shaping_policy_enabled_value  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'enabled', 'value']),
    default_port_config_in_shaping_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'inherited']),
    default_port_config_in_shaping_policy_peak_bandwidth_inherited  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'peakBandwidth', 'inherited']),
    default_port_config_in_shaping_policy_peak_bandwidth_value  => nested_value($spec, ['defaultPortConfig', 'inShapingPolicy', 'peakBandwidth', 'value']),
    default_port_config_ipfix_enabled_inherited  => nested_value($spec, ['defaultPortConfig', 'ipfixEnabled', 'inherited']),
    default_port_config_ipfix_enabled_value  => nested_value($spec, ['defaultPortConfig', 'ipfixEnabled', 'value']),
    default_port_config_lacp_policy_enable_inherited  => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'enable', 'inherited']),
    default_port_config_lacp_policy_enable_value  => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'enable', 'value']),
    default_port_config_lacp_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'inherited']),
    default_port_config_lacp_policy_mode_inherited  => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'mode', 'inherited']),
    default_port_config_lacp_policy_mode_value  => nested_value($spec, ['defaultPortConfig', 'lacpPolicy', 'mode', 'value']),
    default_port_config_network_resource_pool_key_inherited  => nested_value($spec, ['defaultPortConfig', 'networkResourcePoolKey', 'inherited']),
    default_port_config_network_resource_pool_key_value  => nested_value($spec, ['defaultPortConfig', 'networkResourcePoolKey', 'value']),
    default_port_config_out_shaping_policy_average_bandwidth_inherited  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'averageBandwidth', 'inherited']),
    default_port_config_out_shaping_policy_average_bandwidth_value  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'averageBandwidth', 'value']),
    default_port_config_out_shaping_policy_burst_size_inherited  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'burstSize', 'inherited']),
    default_port_config_out_shaping_policy_burst_size_value  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'burstSize', 'value']),
    default_port_config_out_shaping_policy_enabled_inherited  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'enabled', 'inherited']),
    default_port_config_out_shaping_policy_enabled_value  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'enabled', 'value']),
    default_port_config_out_shaping_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'inherited']),
    default_port_config_out_shaping_policy_peak_bandwidth_inherited  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'peakBandwidth', 'inherited']),
    default_port_config_out_shaping_policy_peak_bandwidth_value  => nested_value($spec, ['defaultPortConfig', 'outShapingPolicy', 'peakBandwidth', 'value']),
    default_port_config_security_policy_allow_promiscuous_inherited  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'allowPromiscuous', 'inherited']),
    default_port_config_security_policy_allow_promiscuous_value  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'allowPromiscuous', 'value']),
    default_port_config_security_policy_forged_transmits_inherited  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'forgedTransmits', 'inherited']),
    default_port_config_security_policy_forged_transmits_value  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'forgedTransmits', 'value']),
    default_port_config_security_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'inherited']),
    default_port_config_security_policy_mac_changes_inherited  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'macChanges', 'inherited']),
    default_port_config_security_policy_mac_changes_value  => nested_value($spec, ['defaultPortConfig', 'securityPolicy', 'macChanges', 'value']),
    default_port_config_tx_uplink_inherited  => nested_value($spec, ['defaultPortConfig', 'txUplink', 'inherited']),
    default_port_config_tx_uplink_value  => nested_value($spec, ['defaultPortConfig', 'txUplink', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_beacon_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkBeacon', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_beacon_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkBeacon', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_duplex_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkDuplex', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_duplex_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkDuplex', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_error_percent_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkErrorPercent', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_error_percent_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkErrorPercent', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_speed_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkSpeed', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_check_speed_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'checkSpeed', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_full_duplex_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'fullDuplex', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_full_duplex_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'fullDuplex', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_percentage_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'percentage', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_percentage_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'percentage', 'value']),
    default_port_config_uplink_teaming_policy_failure_criteria_speed_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'speed', 'inherited']),
    default_port_config_uplink_teaming_policy_failure_criteria_speed_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'failureCriteria', 'speed', 'value']),
    default_port_config_uplink_teaming_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'inherited']),
    default_port_config_uplink_teaming_policy_notify_switches_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'notifySwitches', 'inherited']),
    default_port_config_uplink_teaming_policy_notify_switches_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'notifySwitches', 'value']),
    default_port_config_uplink_teaming_policy_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'policy', 'inherited']),
    default_port_config_uplink_teaming_policy_policy_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'policy', 'value']),
    default_port_config_uplink_teaming_policy_reverse_policy_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'reversePolicy', 'inherited']),
    default_port_config_uplink_teaming_policy_reverse_policy_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'reversePolicy', 'value']),
    default_port_config_uplink_teaming_policy_rolling_order_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'rollingOrder', 'inherited']),
    default_port_config_uplink_teaming_policy_rolling_order_value  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'rollingOrder', 'value']),
    default_port_config_uplink_teaming_policy_uplink_port_order_active_uplink_port  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'uplinkPortOrder', 'activeUplinkPort']),
    default_port_config_uplink_teaming_policy_uplink_port_order_inherited  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'uplinkPortOrder', 'inherited']),
    default_port_config_uplink_teaming_policy_uplink_port_order_standby_uplink_port  => nested_value($spec, ['defaultPortConfig', 'uplinkTeamingPolicy', 'uplinkPortOrder', 'standbyUplinkPort']),

    default_port_config_vlan_type_vmware_distributed_virtual_switch_pvlan_spec_inherited      => nested_value($spec, ['defaultPortConfig', 'vlan', 'typeVmwareDistributedVirtualSwitchPvlanSpec','inherited']),
    default_port_config_vlan_type_vmware_distributed_virtual_switch_pvlan_spec_pvlan_id       => nested_value($spec, ['defaultPortConfig', 'vlan', 'typeVmwareDistributedVirtualSwitchPvlanSpec','pvlanId']),
    default_port_config_vlan_type_vmware_distributed_virtual_switch_trunk_vlan_spec_inherited => nested_value($spec, ['defaultPortConfig', 'vlan', 'typeVmwareDistributedVirtualSwitchTrunkVlanSpec','inherited']),
    default_port_config_vlan_type_vmware_distributed_virtual_switch_trunk_vlan_spec_vlan_id   => nested_value($spec, ['defaultPortConfig', 'vlan', 'typeVmwareDistributedVirtualSwitchTrunkVlanSpec','vlanId']),
    default_port_config_vlan_type_vmware_distributed_virtual_switch_vlan_id_spec_inherited    => nested_value($spec, ['defaultPortConfig', 'vlan', 'typeVmwareDistributedVirtualSwitchVlanIdSpec','inherited']),
    default_port_config_vlan_type_vmware_distributed_virtual_switch_vlan_id_spec_vlan_id      => nested_value($spec, ['defaultPortConfig', 'vlan', 'typeVmwareDistributedVirtualSwitchVlanIdSpec','vlanId']),
  }
}
