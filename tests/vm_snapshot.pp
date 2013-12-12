# Copyright (C) 2013 VMware, Inc.
import 'data_snapshot.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
vm_snapshot { 'name':
  name => test_dkumar,
  ensure => present,
  #snapshot_name => name11,
  snapshot_operation => revert,
  datacenter => DDCQA,
  transport => Transport['vcenter'],
}
