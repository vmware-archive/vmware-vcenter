# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

  The VMware/vCenter module uses the VMware vCenter Ruby SDK (rbvmomi, version 1.6.0) to interact with the VMware vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------
	- create
	- destroy
	- nics
	- num_ports
	- nicorderpolicy
	- mtu
	- checkbeacon
	
# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------

	1. create
		This method configures a vSwitch on the ESXi host and also attaches the nics(if any) with the vSwitch.
   
	2. destroy
		This method destroys the vSwitch configured on ESXi host.
	 
	3. nics
		This method is used to configure physical network adapters on a vSwitch 
		
	4. nicorderpolicy
		This method is used to configure Failover Order policy for network adapters on this vSwitch.
		
	5. mtu
		This method is used to configure the maximum transmission unit (MTU) of the virtual switch in bytes.
		
	6. checkbeacon
		This method is used to configure the flag to indicate whether or not to enable this property. If this property is enabled, it enables the beacon probing method to validate the link status of a physical network adapter.

# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------

	ensure: (Optional) This parameter is required to call the 'Create' or 'Destroy' method.
            Possible values: "present" and "absent"
            Default value: present
            If the 'ensure' parameter is set to "present", then it calls the 'create' method.
            If the 'ensure' parameter is set to "absent", then it calls the 'destroy method.

	name: (Required) This parameter defines the name or IP address of the host to which vSwitch needs to be added. It also defines the name of the vSwitch to be created. If this parameter is not provided explicitly in the manifest file, then the title of the type 'esx_vswitch' is used. 
	
	vswitch: (Required) This parameter defines the name of vSwitch to be created.
	
	host: (Required) This parameter defines the ESXi host IP or host name.

	path: (Required) This parameter defines the path to the ESXi host.
	
	num_ports: (Optional) This parameter defines the number of ports that this vSwitch is configured to use. Changing this setting does not take effect until the next reboot. The maximum value is 1024, although other constraints, such as memory limits, may establish a lower effective limit. 
               Default value: 128
    
    nics: (Optional) This parameter defines the array of the physical network adapters to be bridged. If an empty array is defined, then any physical network adapters bridged to the vSwitch will be deleted or unset.
	      Default: Nics property will remain unchanged if nics property is not specified in manifest file.
	
	nicorderpolicy: (Optional) This parameter specifies the Failover Order policy for network adapters on this vSwitch. It is a map of array which contains activenic and standbynic as key to respective arrays.
			activenic: This parameter is an array which specifies the order in which active nics are to be configured based on the Failover Order policy.
			standbynic: This parameter is an array which specifies the order in which standbynic nics are to be configured based on the Failover Order policy.
			By default, if this policy is not defined, then all nice will be moved to unused category.
	
	mtu: (Optional) This parameter specifies the maximum transmission unit (MTU) of the vSwitch in bytes.
	     Default value: 1500
	
	checkbeacon: (Optional) This method is used to configure the flags to indicate whether or not to enable this property. If this property is  enabled, it enables the beacon probing method to validate the link status of a physical network adapter.
	              Default value: true
	
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}


#Configures vSwitch on ESXi host
esx_vswitch { "esx1:vSwitch1":
  ensure    => present,
  name      => "esx1:vSwitch1",
  path      => "/dc1/cl1/",
  num_ports => 120,
  nics      => ["pnic1", "pnic2", "pnic3", "pnic4"],
  nicorderpolicy => {
    activenic  => ["pnic1", "pnic2"],
    standbynic => ["pnic3", "pnic4"]
  },
  mtu            => 1500,
  checkbeacon    => true,
  transport => Transport['vcenter'],
}

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply esx_vswitch.pp for various operations, for example: 
   # puppet apply esx_vswitch.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
