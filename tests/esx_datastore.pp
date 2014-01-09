# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_datastore { "${esx1['hostname']}:<vmfs_datastore>":
  ensure       => present,
  type         => 'vmfs',
  target_iqn   => 'fc.5000d310005ec401:5000d310005ec437', # in case of iSCSI, FC or FCoE luns
  #path         => '/AS1000DC/DDCCluster/',
  #lun         => '100',                                 # in case of SCSI lun
  #remote_host => '192.168.232.1',                       # in case of nfs datastore
  #remote_path => '/Users/nan/src/nodejs',               # in case of nfs datastore
  transport    => Transport['vcenter'],
}
