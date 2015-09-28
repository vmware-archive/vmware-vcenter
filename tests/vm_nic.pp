import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vm_nic { $vnic :
  ensure               => present,  
  vm_name              => $vmname,
  datacenter           => $datacenter,
  type                 => $nic_type,
  portgroup            => $portgroup,
  portgroup_type       => $portgroup_type,
#  start_connected      => $startConnected,
#  wake_on_lan_enabled  => $wakeOnLan,
#  status               => 'ok',
#  allow_guest_control  => $guestControlled,
#  connected            => 'true',
  transport            => Transport['vcenter'],
}

#create_resources(vm_vmxnet3, $nics, $nic_defaults)
