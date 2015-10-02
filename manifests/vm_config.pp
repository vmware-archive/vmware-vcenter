class vcenter::vm_config (
  $vc_username,
  $vc_password,
  $vc_hostname,
  $vm_name,
  $datacenter,
  $transport_options       = {},
  $vm_nics                 = {},
  $vm_harddisks            = {},
  $vapp_properties         = {},
  $num_cpus                = undef,
  $num_cores               = undef,
  $memory                  = undef,
  $ich7m                   = undef,
  $smc                     = undef,
  $power_state             = 'poweredOn',
) {

  $default_transport_options = {
    'rev' => '5.5',
    'insecure' => true
  }
  $merged_options = merge($default_transport_options, $transport_options)
  transport { "vcenter":
    username => $vc_username,
    password => $vc_password,
    server   => $vc_hostname,
    options  => $merged_options,
  }

  $resource_defaults = {
    vm_name    => $vm_name,
    datacenter => $datacenter,
    transport  => Transport["vcenter"],
    before     => Vc_vm[$vm_name]
  }

  if !empty($vapp_properties) {
    create_resources(vm_vapp_property, $vapp_properties, $resource_defaults)
  }

  if !empty($vm_nics) {
    create_resources(vm_nic, $vm_nics, $resource_defaults)
  }
  
  if !empty($vm_harddisks) {
    create_resources(vm_harddisk, $vm_harddisks, $resource_defaults)
  }
  
  vm_hardware { $vm_name :
    datacenter             => $datacenter,
    num_cpus               => $num_cpus,
    num_cores_per_socket   => $num_cores,
    memory_mb              => $memory,
    virtual_ich7m_present  => $ich7m,
    virtual_smc_present    => $smc,
    transport              => Transport['vcenter'],
    before                 => Vc_vm[$vm_name]
  }

  vc_vm { $vm_name :
    power_state       => $power_state,
    datacenter_name   => $datacenter,
    transport         => Transport["vcenter"],
  }
}
