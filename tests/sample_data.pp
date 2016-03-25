# Copyright (C) 2013 VMware, Inc.

$vcenter = {
  'username' => 'root',
  'password' => 'vmware',
  'server'   => '192.168.1.1',
  'options'  => { 'insecure' => true }
}

$dc1 = {
  'name' => 'testdc1',
  'path' => '/testdc1',
}
$dc2 = {
  'name' => 'testdc2',
  'path' => '/testdc2',
}

$cluster1 = {
  'name' => "testdc1/cluster1",
  'path' => "/testdc1/cluster1"
}
$cluster2 = {
  'name' => "testdc1/cluster2",
  'path' => "/testdc1/cluster2"
}
$cluster3 = {
  'name' => "testdc1/cluster3",
  'path' => "/testdc1/cluster3"
}

$log_host = $vcenter['server']

$esx_shared_username = 'root'
$esx_shared_password = 'happyHolidays'

$esx1 = {
  'username' => $esx_shared_username,
  'password' => $esx_shared_password,
  'hostname' => 'esx1.nosuchdomain.',
}
$esx2 = {
  'username' => $esx_shared_username,
  'password' => $esx_shared_password,
  'hostname' => 'esx2.nosuchdomain.',
}
$esx3 = {
  'username' => $esx_shared_username,
  'password' => $esx_shared_password,
  'hostname' => 'esx3.nosuchdomain.',
}
$esx4 = {
  'username' => $esx_shared_username,
  'password' => $esx_shared_password,
  'hostname' => 'esx4.nosuchdomain.',
}
$esxA = {
  'username' => $esx_shared_username,
  'password' => $esx_shared_password,
  'hostname' => 'nosuchhost.',
}

$nfs_datastore1 = {
  'name' => 'ds1',
  'remote_host' => '172.16.231.1',
  'remote_path' => '/exports/ds1',

}
$nfs_datastore2 = {
  'name' => 'ds2',
  'remote_host' => '172.16.231.1',
  'remote_path' => '/exports/ds2',
}

$vm1 = {
  'name'  => 'test',
  'power_state' => 'poweredOn',
}

# the complete list is available by: 
# 1. browsing to https://<vcenter>/mob/?moid=ServiceInstance&method=retrieveContent
# 2. click on Invoke Method
# 3. select VpxSettings, just strip the 'setting[]' from any item
$vpx_settings = {
  'event.maxAgeEnabled' => false,
  'event.maxAge'        => l4,
}

# Sample data for vm_hardware, vm_nic and vm_harddisk
$vmname = 'vm1'
$datacenter = 'testdc1'

###  vm_hardware
$num_cpus   = '4'
$num_cores  = 1
$memory     = 2048
$ich7m      = false
$smc        = false

###  vm_virtualdisk
$hdd             = 'Hard disk 2'
$shareLevel      = 'high'
$capacity        = 8388608
$diskMode        = 'persistent'
$controller      = "SCSI controller 0"

###  vm_vmxnet3
$vnic            = 'Network adapter 2'
$nic_type        = 'e1000e'
$portgroup       = 'VM Network'
$portgroup_type  = 'standard'
$startConnected  = true
$guestControlled = true
$wakeOnLan       = false
