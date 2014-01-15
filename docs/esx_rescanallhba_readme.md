
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------
 
The VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.
 
# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------
 
- Create
# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------
 
  1. Create
  This method generates a request to rescan ESXi host bus adapters for new storage devices.
  This rescan of storage devices is needed when a storage device has been added, removed, or changed.
  The HBA re-scan and VMFS re-scan is to be performed in separate tasks. This is required because the rescan and VMFS 
  datastore detection are asynchronous processes, which can cause the detection process for new datastore to complete before 
  the detection of new LUNs is complete.
  The re-scanning must be followed by refreshing of the storage system to detect the changes occurred, if any.
   
# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------
   
    ensure: (Required) This parameter is required to call the Create method.
    Possible values: present/absent
    Default is : present
 
    host: (Required) This parameter defines the name/IP of the host machine.     
	
	path: (Required) This parameter defines the path to the ESXi host.
 
 
# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------
 
transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}
 
esx_rescanallhba {$newVM['host']:
  ensure  => present,
  host => $newVM['host'],
  path => '/Datacenter1',
  transport  => Transport['vcenter'],
}
 
 
# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
  A user can provide inputs for 'host' in data.pp, and apply esx_rescanallhba.pp for various operations, for example:
   # puppet apply esx_rescanallhba.pp
 
#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------
 