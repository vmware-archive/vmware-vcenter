
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Create
	- Destroy
	

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Create
     This method registers the virtual machine to the inventory.

   
  2. Destroy
     This method removes the Virtual Machine from the inventory.

  
# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

   
    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of ensure parameter is set to present, the Create method is called.
    If the value of ensure parameter is set to absent, the Destroy method is called.
	
	name: (Required) While registering virtual machine this indicates name by which virtual machine is to be registered. 
	      While removing virtual machine from inventory it indicates name of virtual machine which needs to be removed.
	
	datacenter:(Required) Name of DataCenter.
	
	#To register virtual machine 		
	hostip:(Required) IP address the target host on which the virtual machine will run.
	astemplate:(Required) Flag to specify whether or not the virtual machine should be marked as a template.
	vmpath_ondatastore:(Required) A datastore path to the virtual machine.  
	
    


# -------------------------------------------------------------------------
# Parameter signature 
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
   Examples can be referred in the test directory.
   
   User can provide inputs in data_regsitervm.pp, and apply vc_vm_register.pp to register or remove virtual machine to/from inventory
   e.g,
   # puppet apply vc_vm_register.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
