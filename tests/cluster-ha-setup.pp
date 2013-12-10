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

vc_cluster { "${cluster1['path']}":
  ensure    => present,
  transport => Transport['vcenter'],
  #
  before => Anchor["${cluster1['path']}"],
}
vc_cluster_drs { "${cluster1['path']}":
  enabled => true,
  enable_vm_behavior_overrides => true,
  default_vm_behavior => 'fullyAutomated',
  vmotion_rate => 1,
  transport => Transport['vcenter'],
  #
  require => Vc_cluster["${cluster1['path']}"],
  before => Anchor["${cluster1['path']}"],
}
vc_cluster_evc { "${cluster1['path']}":
  # use 'disabled' or 'intel-westmere'
  evc_mode_key => 'disabled',
  transport => Transport['vcenter'],
  #
  require => Vc_cluster_drs["${cluster1['path']}"],
  before => Anchor["${cluster1['path']}"],
}
anchor { "${cluster1['path']}":
}

vc_cluster { "${cluster2['path']}":
  ensure    => present,
  transport => Transport['vcenter'],
  #
  before => Anchor["${cluster2['path']}"],
}
vc_cluster_drs { "${cluster2['path']}":
  enabled => true,
  enable_vm_behavior_overrides => false,
  default_vm_behavior => 'manual',
  vmotion_rate => 4,
  transport => Transport['vcenter'],
  #
  require => Vc_cluster["${cluster2['path']}"],
  before => Anchor["${cluster2['path']}"],
}
vc_cluster_evc { "${cluster2['path']}":
  evc_mode_key => 'disabled',
  transport => Transport['vcenter'],
  #
  require => Vc_cluster_drs["${cluster2['path']}"],
  before => Anchor["${cluster2['path']}"],
}
anchor { "${cluster2['path']}":
}

vcenter::host { [
    "${esx1['hostname']}",
    "${esx2['hostname']}",
  ]:
  path      => "${cluster1['path']}",
  username  => "${esx_shared_username}",
  password  => "${esx_shared_password}",
  transport => Transport['vcenter'],
}

vcenter::host { [
    "${esx3['hostname']}",
    "${esx4['hostname']}",
  ]:
  path      => "${cluster2['path']}",
  username  => "${esx_shared_username}",
  password  => "${esx_shared_password}",
  transport => Transport['vcenter'],
}

esx_syslog { [
    "${esx1['hostname']}",
    "${esx2['hostname']}",
    "${esx3['hostname']}",
    "${esx4['hostname']}",
  ]:
  log_dir_unique => true,
  transport      => Transport['vcenter'],
  log_host       => "${log_host}",
}

esx_datastore { [
      "${esx1['hostname']}:${nfs_datastore1['name']}",
      "${esx2['hostname']}:${nfs_datastore1['name']}",
      "${esx3['hostname']}:${nfs_datastore1['name']}",
      "${esx4['hostname']}:${nfs_datastore1['name']}",
    ]:
  ensure      => present,
  type        => 'nfs',
  remote_host => "${nfs_datastore1['remote_host']}",
  remote_path => "${nfs_datastore1['remote_path']}",
  transport   => Transport['vcenter'],
}
esx_datastore { [
      "${esx1['hostname']}:${nfs_datastore2['name']}",
      "${esx2['hostname']}:${nfs_datastore2['name']}",
      "${esx3['hostname']}:${nfs_datastore2['name']}",
      "${esx4['hostname']}:${nfs_datastore2['name']}",
    ]:
  ensure      => present,
  type        => 'nfs',
  remote_host => "${nfs_datastore2['remote_host']}",
  remote_path => "${nfs_datastore2['remote_path']}",
  transport   => Transport['vcenter'],
}
