import 'data.pp'

$migrate_vm = {
    vmname => 'testVM',
    target_datastore => 'datastore3' ,
    target_host => '172.16.100.56' ,
    target => '172.16.100.56, gale-fsr',
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
    #migratevm_host => $migrate_vm['target_host'],
    #migratevm_host_datastore => $migrate_vm['target'],
    datacenter => $migrate_vm['datacenter'],
    disk_format => 'thin' ,
    transport   => Transport['vcenter'],
}
