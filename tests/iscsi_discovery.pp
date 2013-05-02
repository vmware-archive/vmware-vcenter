# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vcenter::iscsi_discovery { "${esx1['hostname']}:vmhba33":
  transport                 => Transport['vcenter'],
  hostInternetScsiHbaDiscoveryProperties => {
    send_targets_discovery_enabled  => true,
    slp_discovery_enabled           => false,
    # slp_discovery_method            => 
    i_sns_discovery_enabled         => false,
    # slp_host                        => 
    # i_sns_discovery_method          => 
    static_target_discovery_enabled => false,
    # i_sns_host                      => 
  },
}
