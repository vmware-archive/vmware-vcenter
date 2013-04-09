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

$esx_shared_password = 'happyHolidays'
$esx_shared_username = 'root'

$esx1 = {
  'username' => $esx_shared_password,
  'password' => $esx_shared_username,
  'hostname' => 'esx1.nosuchdomain.',
}
$esx2 = {
  'username' => $esx_shared_password,
  'password' => $esx_shared_username,
  'hostname' => 'esx2.nosuchdomain.',
}
$esx3 = {
  'username' => $esx_shared_password,
  'password' => $esx_shared_username,
  'hostname' => 'esx3.nosuchdomain.',
}
$esx4 = {
  'username' => $esx_shared_password,
  'password' => $esx_shared_username,
  'hostname' => 'esx4.nosuchdomain.',
}
$esxA = {
  'username' => $esx_shared_password,
  'password' => $esx_shared_username,
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
