# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the VMware vCenter Ruby SDK (rbvmomi, version 1.6.0) to interact with the VMware vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

    - Create
        
	- Destroy

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

  1. Create
     This method adds FCoE software adapter to a host. 
   
  2. Destroy
     This method deletes FCoE software adapter from a host.

# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------
    
	ensure: (Required) This parameter is required to call the 'Create' or 'Destroy' method.
    The possible values are: "Present" and "Absent"
    If the ensure parameter is set to "Present", the module calls the 'Create' method.
    If the ensure parameter is set to "Absent", the module calls the 'Destroy' method.

	name: (Required) This parameter defines the name or IP address of the host to which a FCoE adapter needs to be added. It also defines the name of the underlying physical NIC that will be associated with the FCoE HBA. If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_fcoe' is used. 
		
    host: (Required) This parameter defines the name or IP address of the host.         

    physical_nic: (Required) This parameter defines the name of the underlying physical NIC that will be associated with the FCoE HBA. If this parameter is not defined explicitly in the manifest file, then the title of the type 'esx_fcoe' is used.

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

#Provide FCoE HBA property
esx_fcoe { "${esx1['hostname']}:vmnic0":
  ensure         => present,
  path			 => '<Datacenter path>'
  transport      => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   You can provide the inputs in the data.pp, and apply esx_fcoe.pp for various operations, for example: 
   # puppet apply esx_fcoe.pp
   
#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------   
