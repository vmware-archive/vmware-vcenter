# Copyright (C) 2013 VMware, Inc.  All Rights Reserved.  All Rights Reserved.
$vcenter = {
  'username' => 'administrator',
  'password' => 'iforgot@123',
  'server'   => '172.16.100.167',
  'options'  => { 'insecure' => true }
}

$dc1 = {
  'name' => 'DDCQA',
  'path' => '/DDCQA',
}

$dc2 = {
  'name' => 'dc2',
  'path' => '/dc2',
}

$esx1 = {
  'username' => 'root',
  'password' => 'password',
  'hostname' => '172.16.100.56',
}

