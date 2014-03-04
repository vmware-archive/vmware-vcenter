# Copyright (C) 2013 VMware, Inc.  All Rights Reserved.  All Rights Reserved.
$vcenter = {
  'username' => 'administrator',
  'password' => 'iforgot@123',
  'server'   => '172.16.100.167',
  'options'  => {
    'insecure' => true
  }
}

$goldVMName = {
  'name' => 'vShield Manager',
}

$createVM = {
    # disk size should be in KB
    'disksize'                      => 4096,
    'memory_hot_add_enabled'        => true,
    'cpu_hot_add_enabled'           => true,
    # user can get the guestif from following url
    # http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fvim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    'guestid'                       => 'winXPProGuest',
    'portgroup'                     => 'VM network',
    'nic_count'                     => 1,
    'nic_type'                      => 'E1000',
    'scsi_controller_type'          => 'LSI Logic SAS',
}

$cloneVM = {
  'dnsDomain'                       => 'asm.test',
  'guestCustomization'              => 'false',
  'guesthostname'                   => 'ClonedVM',
  'guesttype'                       => 'linux',
  'linuxtimezone'                   => 'EST',
  'windowstimezone'                 => '035',
  'guestwindowsdomain'              => '',
  'guestwindowsdomainadministrator' => '',
  'guestwindowsdomainadminpassword' => '',
  'windowsadminpassword'            => 'iforgot',
  'productid'  => '',
  'windowsguestowner'               => 'TestOwner',
  'windowsguestorgnization'         => 'TestOrg',
  'autologoncount'                  => '',
  'autousers'                       => '',
  'ip1'                             => '172.21.95.80',
  'subnet1'                         => '255.255.240.0',
  'dnsserver1'                      => '172.21.88.100',
  'gateway1'                        => '172.21.95.254',
  'ip2'                             => '172.21.95.81',

}

$newVM = {
  'vmName'                          => 'UbuntuCloneGuestVM',
  # operation value can be create or clone
  'operation'                       => 'create',
  'memoryMB'                        => '2048',
  'numCPU'                          => 2,
  'cluster'                         => '',
  'host'                            => '172.16.100.56',
  'target_datastore'                => 'gale-fsr' ,
  'datacenter'                      => 'DDCQA',
  'ensure'                          => 'present',
  
}
$esx1 = {
  'hostname' => '172.16.100.56'
}
