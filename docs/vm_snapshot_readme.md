# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------
 
The VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.
 
# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------
- snapshot_operation
- CreateSnapshot
- RevertToSnapshot
- RemoveSnapshot
 
# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------
 
1.      A snapshot is a reproduction of the Virtual Machine, in a state that exists when the snapshot is taken using the snapshot feature. The snapshot includes the state of the data on all Virtual Machine disks, and the Virtual Machine power state (on, off, or suspended). A snapshot can be taken when a Virtual Machine is powered on, powered off, or suspended. When a snapshot is created, the system creates a delta disk file for that snapshot in the datastore, and writes any changes to that delta disk. You can later revert to the previous state of the Virtual Machine.
 
  CreateSnapshot : This method creates a new snapshot of the Virtual Machine. 
  RevertToSnapshot : This method reverts the virtual machine to the current snapshot. When a snapshot is reverted back, Virtual Machine is restored to the state it was in, when the snapshot was taken.
    RemoveSnapshot :- Deletes the snapshot of the virtual machine     
  
# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------
   
    name: This parameter defines the name of the Virtual Machine.
   
    ensure: This parameter is required to call the snapshot_operation.
    Possible values: present/absent
    
snapshot_operation: This parameter is required to execute the create, revert, or remove operations.
Possible values: create, revert, remove
 
    datacenter: This parameter defines the name of the datacenter.    
 
 
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------
 
transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}
 
 
vm_snapshot { $newVM['name']:
  name => $newVM['vm_name'],
 
  ensure => present,
  snapshot_operation => $newVM['operation'],
  datacenter => $newVM['datacenter'],
  transport => Transport['vcenter'],
}
 
# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples, in the test directory.
   
   A user can provide inputs in data.pp, and apply vm_snapshot.pp for various operations, for example:
   # puppet apply vm_snapshot.pp
 
#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------
 