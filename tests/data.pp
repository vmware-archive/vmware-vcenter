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
  'name' => 'Ubuntu_withTools',
}

$newVM = {
  'vmName'     => 'UbuntuCloneGuestVM',
  'memoryMB'   => '2048',
  'dnsDomain'  => 'asm.test',
  'numCPU'     => 2,
  'cluster'    => '',
  'host'       => '172.16.100.56',
  'target_datastore' => 'datastore1' ,
  'datacenter' => 'DDCQA',
  'ensure'     => 'absent',
  'guestCustomization'              => 'true',
  'guesthostname'                   => 'ClonedVM',
  'guesttype'  => 'linux',
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
  'autousers'  => '',
  'ip1'        => '172.21.95.80',
  'subnet1'    => '255.255.240.0',
  'dnsserver1' => '172.21.88.100',
  'gateway1'   => '172.21.95.254',
}
$esx1 = {
  'hostname' => '172.16.100.56'
}
