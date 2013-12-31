# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

    - Create
        
	- Destroy

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

  1. Create
     The Create method adds FCoE software adapter to a host. 
   
  2. Destroy
     The Destroy method deletes FCoE software adapter from a host.

# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------
    
	ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: Present/Absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.

	physical_nic: (Required) This parameter defines the name of the underlying physical Nic that will be associated with the FCoE HBA. If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_fcoe' is used. 
		
    host: (Required) This parameter defines the name or IP address of the host. 

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
esx_fcoe { 'vmnic1':
  ensure         => present,
  host           => "${esx1['hostname']}",
  transport      => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply esx_fcoe.pp for various operations, for example: 
   # puppet apply esx_fcoe.pp
   
#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------   
