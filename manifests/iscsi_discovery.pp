# Copyright (C) 2013 VMware, Inc.
# Manage iSCSI Discovery
define vcenter::iscsi_discovery (
  $hostInternetScsiHbaDiscoveryProperties = {},
    # transport is a metaparameter
) {

  $path = $name
  $disc_props = $hostInternetScsiHbaDiscoveryProperties
  esx_iscsi_hba_discovery { $path:
    transport               => $transport,
    port_key                => nested_value($disc_props, ['distributedVirtualPort', 'portKey']),
    dvswitchname            => nested_value($disc_props, ['distributedVirtualPort', 'switchUuid']),
    connection_cookie       => nested_value($disc_props, ['distributedVirtualPort', 'connectionCookie']),
    dvportgroupname         => nested_value($disc_props, ['distributedVirtualPort', 'portgroupKey']),
    dhcp                    => nested_value($disc_props, ['ip', 'dhcp']),
    ip_address              => nested_value($disc_props, ['ip', 'ipAddress']),
    subnet_mask             => nested_value($disc_props, ['ip', 'subnetMask']),
    mtu                     => nested_value($disc_props, ['mtu']),
    standardportgroupname   => nested_value($disc_props, ['portgroup']),
    tso_enabled             => nested_value($disc_props, ['tsoEnabled']),
    mac                     => nested_value($disc_props, ['mac']),
  }
}