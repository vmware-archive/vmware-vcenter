import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vm_hardware { $vmname :
  datacenter             => $datacenter,
  num_cpus               => $num_cpus,
  num_cores_per_socket   => $num_cores,
  memory_mb              => $memory,
  virtual_ich7m_present  => $ich7m,
  virtual_smc_present    => $smc,
  transport              => Transport['vcenter'],
} 
