# Copyright (C) 2013 VMware, Inc.  All Rights Reserved.  All Rights Reserved.
$vcenter = {
  'username' => 'administrator',
  'password' => 'iforgot@123',
  'server'   => '172.16.100.167',
  'options'  => {
    'insecure' => true
  }
}

$newVM = {
  'ensure'             => 'absent',
  'name'               => 'test_pankaj',
  'hostip'             => '172.16.100.56',
  'datacenter'         => 'DDCQA',
  'vmpath_ondatastore' => '[gale-fsr] testvm_pankaj/testvm_pankaj.vmx',
  'astemplate'         => 'false',
}
