# Copyright (C) 2013 VMware, Inc.  All Rights Reserved.  All Rights Reserved.
$vcenter = {
	'username' => 'aidev\administrator',
	'password' => 'P@ssw0rd',
	'server'   => '172.28.10.6',
	'options'  => { 'insecure' => true }
}

$dc1 = {
	'name'   =>  'AS100DC',
	'path'   =>  '/AS1000DC',
}

$esx1 = {
	'hostname'   =>  '172.28.8.104',
	'username'   =>  'root',
	'password'   =>  'P@ssw0rd',
}

$mem = {
    'script_executable_path'    => '/usr/bin/perl',
    'setup_script_filepath'     => '/root/scripts/setup.pl',
}

$configure_mem = {
    'storage_groupip'           => '172.16.12.10',
    'iscsi_vmkernal_prefix'     => 'iSCSI',
    'iscsi_vswitch'             => 'vSwitch3',
    'vnics_ipaddress'           => '172.16.12.101,172.16.12.102',
    'iscsi_netmask'             => '255.255.255.0',
    'vnics'                     => 'vmnic6,vmnic7',
    'disable_hw_iscsi'          => 'false',
    'iscsi_chapuser'            => 'demoChap',
    'iscsi_chapsecret'          => 'demoChap',
}

$esx_ds = {
	type => 'vmfs',
	target_iqn => 'iqn.2001-05.com.equallogic:0-1cb196-fb073302b-cb0b10f86ba52caf-demovolume',
}