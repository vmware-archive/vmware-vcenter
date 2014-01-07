# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Create
	- Destroy

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

  1. Create
     This method binds the HBA to the VMkernel NICs.
   
  2. Destroy
     This method unbinds the HBA to the VMkernel NICs.
  
# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

    ensure: (Required) This parameter calls the Create or Destroy method.
    Possible values: Present/Absent
    If the value of ensure parameter is set to present, the Create method is called.
    If the value of ensure parameter is set to absent, the Destroy method is called.
	
	vmknics: (Required) This parameter defines the name of the VMkernel NIC. This parameter can contain multiple values with the space separated.
	
	script_executable_path: (Required) This parameter defines the path of the installed binary of the VMWare perl lib (/usr/bin/esxcli).

	host_name: (Required) The parameter defines the name of the ESX host.
	
	host_username: (Required) The parameter defines the username of the ESX host.
	
	host_password: (Required) The parameter defines the password of the ESX host.


# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

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

iscsi_intiator_binding { "${esx_host['host_name']}:<vmhba>":
  ensure                    => present,
  vmknics                   => $iscsi_details['vmknics'],
  script_executable_path    => $esx_host['script_executable_path'],
  host_username             => $esx_host['host_username'],
  host_password             => $esx_host['host_password'],
  transport                 => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
  A user can provide the inputs in the iscsi_intiator_binding.pp, and apply the iscsi_intiator_binding.pp to bind or unbind the HBA to the VMKernel NIC, for example: 
   # puppet apply iscsi_intiator_binding.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	