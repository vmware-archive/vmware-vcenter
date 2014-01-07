# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- configure_mem
	- install_mem

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

   
  1. configure_mem
     The method configures MEM on the ESX server, and ensures the iSCSI end to end communication between the ESXi server and the iSCSI storage. 

  2. install_mem
     This method installs MEM software on the ESX server.
  
# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------

    configure_mem: (Required for the configure_mem operation) This parameter calls the configure_mem operation.
    Possible values: true

    install_mem: (Required for the install_mem operation) This parameter calls the install_mem operation.
    Possible values: true

    name: (Required)  The parameter defines the name of the ESX host.

    host_username: (Required) The parameter defines the username of the ESX host.
	
	host_password: (Required) The parameter defines the password of the ESX host.

    script_executable_path: (Required) This parameter defines the setup script executable path (/usr/bin/perl). 

    setup_script_filepath: (Required) This parameter defines the path of the MEM setup script. 

    vnics: (Required for the configure_mem operation) This parameter defines the ESX server physical NICs to use for iSCSI. This parameter can contain multiple values in a comma (,) separated format.

    vnics_ipaddress: (Required for configure_mem operation) This parameter defines the IP addresses to be used for iSCSI VMkernel ports. This parameter can contain multiple values in a comma (,) separated format.
    
    iscsi_vswitch: (Required for the configure_mem operation) This parameter defines the name of the iSCSI vSwitch.

    mtu: (Optional for configure_mem operation) This parameter defines the MTU for iSCSI vSwitch and VMkernel ports. 
    Default: 9000

    vmknics: (Required) This parameter defines the name of the VMkernel NIC. This parameter can contain multiple values with the space separated.
  
    iscsi_vmkernal_prefix: (Required for the configure_mem operation) This parameter defines the prefix to be used for VMkernel port names.

    iscsi_netmask: (Required for the configure_mem operation) This parameter defines the netmask to be used for iSCSI VMkernel ports.

    disable_hw_iscsi: (Required for the configure_mem operation) This parameter disables the Hardware iSCSI initiator.
    Possible values: true/false
    Default: false    
	
    storage_groupip: (Required for the configure_mem operation) This parameter defines the storage group IP address to be added as an iSCSI Discovery Portal.

    iscsi_chapuser: (Optional for the configure_mem operation) This parameter defines the CHAP username to be used for connecting to the volumes on the storage Group IP.
	
    iscsi_chapsecret: (Required if the iscsi_chapuser value is provided) This parameter defines the CHAP password to be used for connecting to the volumes on the storage Group IP.	
	

# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

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
    'setup_script_filepath'     => '/root/scripts/setup.pl',
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
  install_mem		        => "true",
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

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
  A user can provide the inputs in the iscsi_intiator_binding.pp, and apply the esx_mem.pp to install and configure mem on ESX server, for example: 
   # puppet apply esx_mem.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
