
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------
 
  The VMware/VCenter module uses the VMware vCentre Ruby SDK (rbvmomi, version 1.6.0) to interact with the VMware vCenter.
 
# --------------------------------------------------------------------------
# Supported Functionality
# --------------------------------------------------------------------------
 
  - Create
# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------
 
  1. create
     This method checks whether specified host exists or not. If it is null, then it displays the error message: "host does not exists."
     If the host name exists, it will call the 'change_policy' method to apply the multi-path configuration change.
  
  2. change_policy
     This method performs the actual FC/FCoE multipath configuration changes.
     This method collects all the multipath LUN connected to the host bus adapter (HBA), and then looks for the LUN, which are connected through Fabric Channel (FC) with two or more number of available paths.
     After identifying the FC or FCoE LUNs, the multi-path configuration policy is applied to them one after the other.
     The path selection policy can be selected from one of below mentioned values:
     VMW_PSP_FIXED - Uses a preferred path whenever possible.
     VMW_PSP_RR - Uses Round Robin load balance.
     VMW_PSP_MRU - Uses the most recently used path.
   
# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------
   
    ensure: (Required) This parameter is required to call the 'Create' method.
            The Possible values are: "present" and "absent"
            The Default value is : "present"
 
    host: (Required) This parameter defines the name or IP Address of the host machine.     
	
    policyname: (Required) This property defines the policy that needs to be applied.
	
	path: (Required) This parameter defines the path to the ESXi host.
 
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------
 
 transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_fc_multiple_path_config {$newVM['host']:
  ensure => present,
  host => $newVM['host'],
  policyname => 'VMW_PSP_RR',
  path			 => '/Datacenter1',
  transport   => Transport['vcenter'],
}
 
# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   You can provide inputs for 'host' in data.pp, and apply esx_fc_multiple_path_config.pp for various operations, for example:
   # puppet apply esx_fc_multiple_path_config.pp
 
#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------
 