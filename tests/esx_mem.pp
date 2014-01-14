import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


$mem = {
    'host'                      => '172.16.103.189',
    'script_executable_path'    => '/usr/bin/perl',
    'setup_script_filepath'     => '/opt/Dell/scripts/EquallogicMEM/setup.pl',
    'host_username'             => 'root',
    'host_password'             => 'iforgot@123',
}

$configure_mem = {
    'storage_groupip'           => '192.168.110.3',
    'iscsi_vmkernal_prefix'     => 'iSCSI',
    'iscsi_vswitch'             => 'vSwitch3',
    'vnics_ipaddress'           => '192.168.110.10,192.168.110.11',
    'iscsi_netmask'             => '255.255.255.0',
    'vnics'                     => 'vmnic2,vmnic3',
    'disable_hw_iscsi'          => 'true',
    'iscsi_chapuser'            => 'chap_user1',
    'iscsi_chapsecret'          => 'chap_pwd',
}


esx_mem { $mem['host']:
  configure_mem		        => "true",
  install_mem               => "true",
  script_executable_path    => $mem['script_executable_path'],
  setup_script_filepath     => $mem['setup_script_filepath'],
  host_username             => $mem['host_username'],
  host_password             => $mem['host_password'],
  transport                 => Transport['vcenter'],
  storage_groupip           => $configure_mem['storage_groupip'],
  iscsi_vmkernal_prefix     => $configure_mem['iscsi_vmkernal_prefix'],
  vnics_ipaddress           => $configure_mem['vnics_ipaddress'],
  iscsi_vswitch             => $configure_mem['iscsi_vswitch'],
  iscsi_netmask             => $configure_mem['iscsi_netmask'],
  vnics                     => $configure_mem['vnics'],
  iscsi_chapuser            => $configure_mem['iscsi_chapuser'],
  iscsi_chapsecret          => $configure_mem['iscsi_chapsecret'],
  disable_hw_iscsi          => $configure_mem['disable_hw_iscsi'],
}
