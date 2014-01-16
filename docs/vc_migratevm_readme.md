
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- migratevm_host
	- migratevm_datastore
	- migratevm_host_datastore

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. migratevm_host: This method migrates a VMware Virtual Machine host to another host.
   
  2. migratevm_datastore: This method migrates a VMware Virtual Machine's storage to another datastore.


  3. migratevm_host_datastore: This method migrates a VMware Virtual Machine host to another host and moves its storage to another datastore.



# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------
    
    datacenter: (Required) This parameter defines the name of the dataCenter.

    name: (Required) This parameter defines the name of the new Virtual Machine.
    
    migratevm_host: This parameter calls the 'migratevm_host' functionality to migrate the Virtual Machine host to another specified host.
    Syntax: migratevm_datastore =>  '<target host name>'
    Note: This parameter is required if a Virtual Machine host is to be migrated to another host.
    
    migratevm_datastore: This parameter calls the  'migratevm_datastore' functionality to migrate the Virtual Machine's storage to another specified datastore.
    Syntax: migratevm_datastore =>  '<target datastore name>'
    Note: This parameter is required if a Virtual Machine storage is to be migrated to another datastore.

    migratevm_host_datastore: This parameter calls the 'migratevm_host_datastore' functionality to migrate the VMware Virtual Machine host to another specified host and also migrates its storage to another specified datastore.
    Syntax: migratevm_host_datastore =>  '<target host name, target datastore name>'
    NOTE: This parameter is required if a Virtual Machine host and storage is to be migrated to another host and datastore, respectively.
          Target host and target datastore values must be comma (,) sperated values. The first value is considered as the host nameas the datastore value.
          
    
    diskformat: (Optional, used in case of 'migratevm_datastore' or 'migratevm_host_datastore' functionality) This parameter controls the type of disk created during the cloning operation.
    Possible values: thin/thick/same_as_source
    Default: same_as_source




# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

import 'data.pp'

$migrate_vm = {
    vmname => 'testVM',
    target_datastore => 'datastore3' ,
    target_host => '172.16.100.56' ,
    target => '172.16.100.56, gale-fsr',
    datacenter => 'DDCQA',
   
}

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


vc_migratevm { $migrate_vm['vmname']:
    migratevm_datastore => $migrate_vm['target_datastore'],
    #migratevm_host => $migrate_vm['target_host'],
    #migratevm_host_datastore => $migrate_vm['target'],
    datacenter => $migrate_vm['datacenter'],
    disk_format => 'thin' ,
    transport   => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
  Refer to examples in the tests directory.
   
   A user can provide the inputs in the data.pp, and apply the vc_migratevm.pp for various operations, for example: 
   # puppet apply vc_migratevm.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
