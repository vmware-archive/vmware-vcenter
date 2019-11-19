# Copyright (C) 2013 VMware, Inc.
# Manage dvswitch migration
define vcenter::vc_dvswitch_migrate (
  $vmk0 = '',
  $lag = nil,
  $vmnic0 = nil,
  $vmnic1 = nil,
  $vmnic2 = nil,
  $vmnic3 = nil,
  $vmnic4 = nil,
  $vmnic5 = nil,
  $vmnic6 = nil,
  # transport is a metaparameter
) {

  $path = $name
  vc_dvswitch_migrate { $path:
    transport               => $transport,
    vmk0                    => $vmk0,
    lag                     => $lag,
    vmnic0                  => $vmnic0,
    vmnic1                  => $vmnic1,
    vmnic2                  => $vmnic2,
    vmnic3                  => $vmnic3,
    vmnic4                  => $vmnic4,
    vmnic5                  => $vmnic5,
    vmnic6                  => $vmnic6,
  }
}
