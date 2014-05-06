import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vm_vnic { 'name':
  ensure     => present,
  name       => 'Network adapter 1',
  vm_name    => 'testVm',
  portgroup  => 'PortgroupName',
  nic_type   => 'E1000',
  datacenter => 'DatacenterName',
  transport  => Transport['vcenter'],
}
