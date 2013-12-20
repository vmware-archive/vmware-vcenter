# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

$migrate_vm = {
    vmname => 'testVM',
    target_datastore => 'datastore3' ,
    datacenter => 'DDCQA',
   
}

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


vc_migratevm { $migrate_vm['vmname']:
    migratevm_datastore => $migrate_vm['target_datastore'],
    datacenter => $migrate_vm['datacenter'],
    disk_format => 'thin' ,
    transport   => Transport['vcenter'],
}
