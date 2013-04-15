# Copyright (C) 2013 VMware, Inc.
# Manage ESXi vmknics
define vcenter::vmknic (
  $ensure,
  $portgroup = '',
  $hostVirtualNicSpec = {},
    # transport is a metaparameter
) {

  $path = $name
  $nic = $hostVirtualNicSpec
  esx_vmknic { $path:
    ensure                  => $ensure,
    transport               => $transport,
    portgroup               => $portgroup,
    port_key                => nested_value($nic, ['distributedVirtualPort', 'portKey']),
    dvswitchname            => nested_value($nic, ['distributedVirtualPort', 'switchUuid']),
    connection_cookie       => nested_value($nic, ['distributedVirtualPort', 'connectionCookie']),
    dvportgroupname         => nested_value($nic, ['distributedVirtualPort', 'portgroupKey']),
    dhcp                    => nested_value($nic, ['ip', 'dhcp']),
    ip_address              => nested_value($nic, ['ip', 'ipAddress']),
    subnet_mask             => nested_value($nic, ['ip', 'subnetMask']),
    mtu                     => nested_value($nic, ['mtu']),
    standardportgroupname   => nested_value($nic, ['portgroup']),
    tso_enabled             => nested_value($nic, ['tsoEnabled']),
    mac                     => nested_value($nic, ['mac']),
  }
}
