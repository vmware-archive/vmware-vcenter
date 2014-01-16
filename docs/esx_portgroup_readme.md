
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with the vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

        - Create
        - Destroy
        - Set VLAN Id
        - Set traffic shaping policy
        - Set IP configuration of the port group
		- Override the failover policy
		- Set mtu size
		- Set failback flag
		- Set checkbeacon flag

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Create
     This method creates a port group instance based on the specified input parameters.
     As the port group gets created on a given vSwitch, the specific vSwitch must exist on the specified host.
     A user can set the port group type to either VirtualMachine or VMkernel (Used for vmotion and NIC teaming. Also, the IP address, the traffic shaping policy and the VLAN ID of the port group can be set by the user.
   
  2. Destroy
     This method removes the port group from the specified vSwitch.

  3. Set VLAN ID
     This method sets the VLAN Id of the created port group.
         
  4. Set traffic shaping policy
     This method sets the traffic shaping parameters in terms of average bandwidth, peak bandwidth and the burst size on the created port group.

  5. Set the IP configuration of the port group
     This method sets the IP settings (dhcp/static) on the created port group.
	 Note: To update the IP address, it is required to set the vMotion flag to "Enabled", so that it gets enabled before updating the IP address to either dhcp/static.
	 
  6. override failover policy
	 This method overrides the failover order of vSwitch and sets it as per the input given by the user.
	 
  7. Set mtu size
	 This method sets the MTU size of the created port group.
	
  8. Set failback
	 This method sets the failback flag on the created  port group.
		
  9. Set checkbeacon
	 This method sets the checkbeacon flag on the created port group.
	 
# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------

  name: (Required) This parameter defines the port group to be created or already to be created.
		The name is a combination of host and port group separated by colon.
		example: 172.16.100.56:test05
		
		
  ensure: (Required) This parameter is required to call the Create or Destroy method.
        Valid values: Present/Absent
        If the value of ensure parameter is set to present, the RA calls the Create method.
        If the value of ensure parameter is set to absent, the RA calls the Destroy method.
        Default value: Present

  path: (Required) This parameter defines the path to the host, for example: /Datacenter-1/cluster-1.
        
  vswitch:(Required) This parameter defines the name of the vSwitch.
        
  portgrouptype: (Required) This parameter defines the port group to be created by the user. 
        Valid values : "VirtualMachine" and "VMkernel"
        Default value: "VirtualMachine"

  vmotion: (Optional) This parameter notifies whether or not a vMotion is required on the VMkernel port group. This parameter is optional in case of the port group of the type "virtualMachine".
           Valid values : "Enabled" and "Disabled"
  overridefailback: (Optional) This parameter facilitates the user to override switch failback policy.
			Valid values : "Enabled" and "Disabled"
  overridecheckbeacon: (Optional) This parameter facilitates the user to override switch checkbeacon policy.
			Valid values : "Enabled" and "Disabled"			
			
  failback: This parameter is the value of failback policy.This is required if overridefailback is "Enabled"
			Valid values : "true" and "false"
			
  checkbeacon : This parameter is the value of checkbeacon policy.This is required if overridecheckbeacon is "Enabled" 
           Valid values : "true" and "false"
		   
  mtu :  (Optional) This paramter is used to specify the MTU size for this port group. A valid MTU value must not be less than 1500 and must not exceed 9000.
			
  overridefailoverorder : (Optional) This parameter facilitates the user to override switch failover order.
			Valid values : "Enabled" and "Disabled"
  
  nicorderpolicy : (Optional) This parameter gives option to the user to select active NICs and standby NICs for this port group. The value of this parameter must be in a hash format, for example: 
				nicorderpolicy => {
					activenic  => ["vmnic1"],
					standbynic => []
				},			
  ipsettings: (Optional) This parameter defines the IP settings required on the port group. 
            Valid values : "dhcp" and "static"
                         
  ipaddress: This parameter defines the IP address to be applied on the created port group. This parameter is required if the "ipsettings" parameter value is "static".
        
  subnetmask: This parameter is the subnetmask to be applied on the created port group. This parameter is required if the "ipsettings" parameter value is "static".

  traffic_shaping_policy: (Optional) This parameter defines the traffic shaping policy to be applied on the port group.
   Valid values : "Enabled", "Disabled"
                         
  averagebandwidth: (Optional) This parameter defines the average bandwidth to be applied on the port group. This parameter is used if the "traffic_shaping_policy" is enabled.
                   Default value: 1000 Kbits/sec
        
  peakbandwidth: (Optional) This parameter defines the peak bandwidth to be applied on the port group. This parameter is used if the "traffic_shaping_policy"" is enabled.
                 Default value: 1000 Kbits/sec
                        
  burtsize: (Optional) This parameter defines the burst size to be applied on the port group. This parameter is used if the traffic_shaping_policy"" is enabled.
            Default value: 1024 Kbytes
                        
  vlanid : (Optional) This parameter defines the VLAN Id to be set on the portgroup.
           Valid value: 0 to 4095
           Default value: 0 (No VLAN)

# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# The following resource is not ready for testing:

  esx_portgroup { 'name':
    name => "172.16.100.56:test05",
    ensure => present,
    portgrouptype => "VMkernel",
    vmotion => "Disabled",
	failback => "true",
	checkbeacon => "false",
	mtu => "2014",
	overridefailoverorder => "Enabled",
	nicorderpolicy => {
    activenic  => ["vmnic1"],
    standbynic => []
	},
    ipsettings => "static",
    ipaddress => "172.16.12.16",
    subnetmask => "255.255.0.0",
    traffic_shaping_policy => "Disabled",
    averagebandwidth => 1000,
    peakbandwidth => 1000,
    burstsize => 1024,
    vswitch => vSwitch1,
    host => "172.16.100.56",
    path => "/Datacenter/cluster-1",
    vlanid => 5,
    transport => Transport['vcenter'],
  }


# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the test directory.
   
   A user can provide the inputs in the data.pp, and apply the esx_portgroup.pp for various operations, for example: 

   # puppet apply esx_portgroup.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------      
