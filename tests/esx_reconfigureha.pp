# Copyright (C) 2013 VMware, Inc.
import 'sample_data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_reconfigureha { 'host':
  host      => $esx['host1'],
  ensure    => present,
  path      => "/datacenter/cluster",
  transport => Transport['vcenter'],
}
