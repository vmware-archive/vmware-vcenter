# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_datastore { "${esx1['hostname']}:nfs_store":
  ensure      => present,
  type        => 'nfs',
  remote_host => '192.168.232.1',
  remote_path => '/Users/nan/src/nodejs',
  transport   => Transport['vcenter'],
}
