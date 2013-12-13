# Copyright (C) 2013 VMware, Inc.  All Rights Reserved.  All Rights Reserved.
$vcenter = {
  'username' => 'administrator',
  'password' => 'iforgot@123',
  'server'   => '172.16.100.167',
  'options'  => { 'insecure' => true }
}


$goldVMName = {
  'name'  => 'Win7GoldVM_WithTools',
}

$newVM = {
  'vmName'  => 'WinCloneGuestVM1',
  
  'memoryMB' => '2048',
  'dnsDomain' => 'asm.test',  
  'numCPU' => 2,
  'cluster' => '',
  'host' => '172.16.100.56',
  'datacenter' => 'DDCQA',
  'ensure' => 'present',
  
  'guestCustomization' => 'true',
  'guesthostname' => 'ClonedVM',
  
  'guesttype' => 'windows',
  
  'linuxtimezone'  => 'EST',
  
  'windowstimezone'  => '035',
  'guestwindowsdomain'  => '',
  'guestwindowsdomainadministrator'  => '',
  'guestwindowsdomainadminpassword'  => '',
  'windowsadminpassword'  =>iforgot,
  'productid'  => '',
  'diskformat'  => 'Thin',
  
  'windowsguestowner' => 'TestOwner',
  'windowsguestorgnization' => 'TestOrg',
  
  'ip1' => "172.21.95.80",
  'subnet1' => '255.255.240.0',
  'dnsserver1' => '172.21.88.100',
  'gateway1' => '172.21.95.254',
}
