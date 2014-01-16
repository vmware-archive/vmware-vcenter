import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


$esx_host = {
    'host_name'                 => '172.28.8.102',
    'script_executable_path'    => '/usr/bin/esxcli',
    'host_username'             => 'root',
    'host_password'             => 'P@ssw0rd',
}

$iscsi_details = {
    # Provide space separated VMkernel nics
    'vmknics'                     => 'vmk1',
}

iscsi_intiator_binding { "${esx_host['host_name']}:vmhba33":
  ensure                    => present,
  vmknics                   => $iscsi_details['vmknics'],
  script_executable_path    => $esx_host['script_executable_path'],
  host_username             => $esx_host['host_username'],
  host_password             => $esx_host['host_password'],
  transport                 => Transport['vcenter'],
}