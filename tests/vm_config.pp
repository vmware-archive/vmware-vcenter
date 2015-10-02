class { 'vcenter::vm_config' :
  vc_username      => 'administrator@vsphere.local',
  vc_password      => 'vmware',
  vc_hostname      => '192.168.1.100',
  vm_name          => 'vm1',
  datacenter       => 'dc1',
  vm_nics          => { 
    'Network adapter 1' => {
       ensure           => present,
       'type'           => 'vmxnet3',
       'portgroup'      => 'VM Network',
       'portgroup_type' => 'standard',
       before           => Vm_nic['Network adapter 2']
    }, 
    'Network adapter 2' => {
      ensure           => present,
      'type'           => 'e1000e',
      'portgroup'      => 'dvpg1',
      'portgroup_type' => 'distributed',
    },
  },
  vm_harddisks     => {
    'Hard disk 2' => {
      'datastore'      => 'datastore1',
      'controller'     => 'SCSI controller 0',
      'level'          => 'normal',
      'capacity_in_kb' => 10485760,
      'disk_mode'      => 'persistent'
    }
  },
  num_cpus          => 4,
  num_cores         => 2,
  memory            => 4096,
}
