
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Create
	- Destroy
	

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Create
     This method registers the virtual machine with the inventory.

   
  2. Destroy
     This method removes the Virtual Machine from the inventory.

  
# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------

   
    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: Present/Absent
    If the value of ensure parameter is set to present, the Create method is called.
    If the value of ensure parameter is set to absent, the Destroy method is called.
	
	name: (Required) This parameter indicates the name by which the Virtual Machine is to be registered, while registering the Virtual Machine. However, while removing the Virtual Machine from the inventory, the "name" parameter indicates the name of the Virtual Machine that is to be removed.
	
	datacenter:(Required) This parameter defines the name of Data Center.
	
	#To register a Virtual Machine 
		
	hostip:(Required) This parameter defines the IP address of the target host on which the Virtual Machine will run.
	astemplate:(Required) This parameter specifies a flag to specify whether or not the Virtual Machine must be marked as a template.
	vmpath_ondatastore:(Required) This parameter describes a  datastore path to the Virtual Machine.  
	
    


# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vm_register { $newVM['name']:
  ensure     => $newVM['ensure'],
  transport  => Transport['vcenter'],
  #to register vm
  datacenter => $newVM['datacenter'],  
  hostip       => $newVM['hostip'],
  astemplate => $newVM['astemplate'],
  vmpath_ondatastore  => $newVM['vmpath_ondatastore'], 
  
 }

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
  A user can provide inputs in data_regsitervm.pp, and apply the vc_vm_register.pp to register or remove the Virtual Machine to/from inventory, for example: 
   # puppet apply vc_vm_register.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
