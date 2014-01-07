
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/vCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- create
	- destroy

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. create: This method creates a new Virtual Machine by importing an OVF file.
   

  2. destroy: This method exports Virtual Machine OVF to a  specified location.


# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------
    
    ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.

    datacenter: (Required) This parameter defines the name of the dataCenter.

    name: (Required) This parameter defines the name of the new Virtual Machine.

    ovffilepath: (Required) This parameter defines the OVF file path.

    target_datastore: (Required) This parameter is used in case of create (import OVF). This parameter defines the name of the datastore where the new Virtual Machine is to be created.

    host: (Required) This parameter is used in case of the create (import OVF) method. This parameter defines the host name where the new Virtual Machine is to be created. 

    diskformat: (Optional) This parameter is used in case of the create (import OVF) method. This parameter controls the type of disk created during the import OVF operation.
    Possible values: thin/thick
    Default: thin



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


$ovf = {
    'vmname'                    => 'testVM',
    'ovffilepath'               => '/root/OVF/test.ovf',
    'datacenter'                => 'DDCQA',
    # For Import ovf
    'target_datastore'          => 'datastore3',
    'host'                      => '172.16.100.56' 
}


vc_vm_ovf { $ovf['vmname']:
  ensure                    => present,
  datacenter                => $ovf['datacenter'],
  ovffilepath               => $ovf['ovffilepath'],
  target_datastore          => $ovf['target_datastore'],
  host                      => $ovf['host'],
  transport                 => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
  Refer to examples in the tests directory.
   
   A user can provide the inputs in the data.pp, and apply the vc_vm_ovf.pp for various operations, for example: 
   # puppet apply vc_vm_ovf.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
