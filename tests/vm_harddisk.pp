import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vm_harddisk { $hdd :
  ensure         => present,  
  datacenter     => $datacenter,
  vm_name        => $vmname,
  datastore      => $datastore,
  controller     => $controller,
  level          => $shareLevel,
  capacity_in_kb => $capacity,
  disk_mode      => $diskMode,
  transport      => Transport['vcenter'],
}

