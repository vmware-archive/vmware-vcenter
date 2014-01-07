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
     The Create method switches the host to maintenance mode. While this task is running and when the host is in the maintenance mode, no virtual machines can be powered on and no provisioning operations can be performed on the host. After the call completion, it is safe to turn off the host without disrupting any virtual machines. 

   
  2. Destroy
     The Destroy method gets the host out of the maintenance mode. This action blocks if any concurrent running maintenance-only host configuration  operations are being performed, for example: if the VMFS volumes are being upgraded. 


# -------------------------------------------------------------------------
# Summary of parameters.
# -------------------------------------------------------------------------

	ensure: (Required) This parameter is required to call the Create or Destroy method.
    Possible values: present/absent
    If the value of the ensure parameter is set to present, the module calls the Create method.
    If the value of the ensure parameter is set to absent, the module calls the Destroy method.


    timeout: The task completes only when the host successfully enters the maintenance mode or the timeout expires, and in the latter case the task  contains a Timeout fault. If the timeout is less than or equal to zero, there is no timeout. The timeout is specified in seconds. 
    
    host: (Required) This parameter defines the host ip/name.
	
	evacuate_powered_off_vms: (Required) This is a parameter that is supported only by the VirtualCenter. If this parameter is set to true, the task does not succeed for a DRS disabled cluster, unless all powered-off virtual machines are manually re-registered. However, if this parameter is set to ture for a DRS enabled cluster, the VirtualCenter automatically re-registers the powered-off virtual machines, and a powered-off virtual machine might remain at the host only for the following two reasons: 

(a) No compatible host is found for re-registration.
(b) DRS is disabled for the virtual machine. 

If this parameter is set to false, the powered-off virtual machines are not required to be moved. 
	
# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------


transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

#Provide any host property
esx_maintmode { 'esx1':
  ensure => present,
  evacuate_powered_off_vms  => true,
  timeout   => $esx1['timeout'],  
  hostdns    => $esx1['host'],
  transport  => Transport['vcenter'],
}
# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply esx_maintmode.pp for various operations, for example: 
   # puppet apply esx_maintmode.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
