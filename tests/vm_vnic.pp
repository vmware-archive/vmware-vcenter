import 'data_snapshot.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
vm_vnic { 'name'
   name => my_Test,
  ensure => present,
  vm_name => test_dkumar,
  nic_type => E1000,
  datacenter => DDCQA,
  transport => Transport['vcenter'],
}