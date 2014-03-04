import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# provide any  prperty of host
esx_maintmode { 'esxhost':
  ensure                   => present,
  evacuate_powered_off_vms => true,
  timeout                  => 0,
  host                     => $esx1['hostname'],
  transport                => Transport['vcenter'],
}
