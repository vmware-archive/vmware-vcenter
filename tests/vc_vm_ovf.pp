import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

$ovf = {
  'vmname'           => 'testVM_1',
  'ovffilepath'      => '/root/OVF/test_123.ovf',
  'datacenter'       => 'DDCQA',
  'target_datastore' => 'datastore3',
  'host'             => '172.16.100.55'
}

vc_vm_ovf { $ovf['vmname']:
  ensure           => 'import',
  datacenter       => $ovf['datacenter'],
  ovffilepath      => $ovf['ovffilepath'],
  target_datastore => $ovf['target_datastore'],
  host             => $ovf['host'],
  transport        => Transport['vcenter'],
}
