# Copyright (C) 2013 VMware, Inc.
# Manage iSCSI Discovery
define vcenter::iscsi_discovery (
  $hostInternetScsiHbaDiscoveryProperties = {},
    # transport is a metaparameter
) {

  $path = $name
  $disc_props = $hostInternetScsiHbaDiscoveryProperties
  esx_iscsi_hba_discovery { $path:
    transport                       => $transport,
    send_targets_discovery_enabled  => nested_value($disc_props, ['sendTargetsDiscoveryEnabled']),
    slp_discovery_enabled           => nested_value($disc_props, ['slpDiscoveryEnabled']),
    slp_discovery_method            => nested_value($disc_props, ['slpDiscoveryMethod']),
    i_sns_discovery_enabled         => nested_value($disc_props, ['iSnsDiscoveryEnabled']),
    slp_host                        => nested_value($disc_props, ['slpHost']),
    i_sns_discovery_method          => nested_value($disc_props, ['iSnsDiscoveryMethod']),
    static_target_discovery_enabled => nested_value($disc_props, ['staticTargetDiscoveryEnabled']),
    i_sns_host                      => nested_value($disc_props, ['iSnsHost']),
  }
}
