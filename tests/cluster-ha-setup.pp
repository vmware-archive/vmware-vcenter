# Copyright (C) 2013 VMware, Inc.
transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => 'vc0.rbbrown.dev'
}

vc_datacenter { 'dc1':
  path      => '/dc1',
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_cluster { '/dc1/clu1':
  ensure    => present,
  transport => Transport['vcenter'],
  #
  before => Anchor['/dc1/clu1'],
}
vc_cluster_drs { '/dc1/clu1':
  enabled => true,
  enable_vm_behavior_overrides => true,
  default_vm_behavior => 'fullyAutomated',
  vmotion_rate => 1,
  transport => Transport['vcenter'],
  #
  require => Vc_cluster['/dc1/clu1'],
  before => Anchor['/dc1/clu1'],
}
vc_cluster_evc { '/dc1/clu1':
  # use 'disabled' or 'intel-westmere'
  evc_mode_key => 'disabled',
  transport => Transport['vcenter'],
  #
  require => Vc_cluster_drs['/dc1/clu1'],
  before => Anchor['/dc1/clu1'],
}
anchor { '/dc1/clu1':
}

vc_cluster { '/dc1/clu2':
  ensure    => present,
  transport => Transport['vcenter'],
  #
  before => Anchor['/dc1/clu2'],
}
vc_cluster_drs { '/dc1/clu2':
  enabled => true,
  enable_vm_behavior_overrides => false,
  default_vm_behavior => 'manual',
  vmotion_rate => 4,
  transport => Transport['vcenter'],
  #
  require => Vc_cluster['/dc1/clu2'],
  before => Anchor['/dc1/clu2'],
}
vc_cluster_evc { '/dc1/clu2':
  evc_mode_key => 'disabled',
  transport => Transport['vcenter'],
  #
  require => Vc_cluster_drs['/dc1/clu2'],
  before => Anchor['/dc1/clu2'],
}
anchor { '/dc1/clu2':
}

vcenter::host { [
    'esx1.rbbrown.dev',
    'esx2.rbbrown.dev',
  ]:
  path      => '/dc1/clu1',
  username  => 'root',
  password  => 'happyHolidays',
  transport => Transport['vcenter'],
}

vcenter::host { [
    'esx3.rbbrown.dev',
    'esx4.rbbrown.dev',
  ]:
  path      => '/dc1/clu2',
  username  => 'root',
  password  => 'happyHolidays',
  transport => Transport['vcenter'],
}

esx_syslog { [
    'esx1.rbbrown.dev',
    'esx2.rbbrown.dev',
    'esx3.rbbrown.dev',
    'esx4.rbbrown.dev',
  ]:
  log_dir_unique => true,
  transport      => Transport['vcenter'],
  log_host       => 'vc0.rbbrown.dev',
}

esx_datastore { [
    'esx1.rbbrown.dev:ds1',
    'esx2.rbbrown.dev:ds1',
    'esx3.rbbrown.dev:ds1',
    'esx4.rbbrown.dev:ds1',
  ]:
  ensure      => present,
  type        => 'nfs',
  remote_host => '172.16.231.1',
  remote_path => '/Volumes/ds1',
  transport   => Transport['vcenter'],
}
esx_datastore { [
      'esx1.rbbrown.dev:ds2',
      'esx2.rbbrown.dev:ds2',
      'esx3.rbbrown.dev:ds2',
      'esx4.rbbrown.dev:ds2',
    ]:
  ensure      => present,
  type        => 'nfs',
  remote_host => '172.16.231.1',
  remote_path => '/Volumes/ds2',
  transport   => Transport['vcenter'],
}
