
# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

VMware/VCenter module uses the vCentre Ruby SDK (rbvmomi Version 1.6.0) to interact with vCenter.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

        - Create
        - Destroy
        - Set vlan Id
        - Set traffic shaping policy
        - Set ip configuration of the port group

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Create
     This method creates a port group instance based on the specified input parameters.
     As the port group will be created on a the given vswitch, this vswitch should exist on the specified host.
     User can set the type of the port group to either VirtualMachine or VMkernel (Used for vmotion and nic teaming).
     Also he can set the ipaddress, traffic shaping policy and vlan id of the port group.
   
  2. Destroy
     This method removes the port group from the specified vswitch.

  3. Set vlan Id
     This method sets the vlanId of the created port group.
         
  4. Set traffic shaping policy
     This method sets traffic shaping parameters in terms of average bandwidth, peak bandwidth and burst size on the created port group.

  5. Set ip configuration of the port group
     This method sets the ip settings (dhcp/static) on the created port group.
	 Note: To update the ip address it is required to set the vmotion flag to "Enabled".So it enabled it before updating the ipaddress to either dhcp/static.

# -------------------------------------------------------------------------
# Summary of Parameters.
# -------------------------------------------------------------------------

  name: (Required) This is the name of the port group to be created/already created.

  ensure: (Required) This parameter is required to call the Create or Destroy method.
        Valid values: present/absent
        If the value of ensure parameter is set to present, the Create method is called by the RA.
        If the value of ensure parameter is set to absent, the Destroy method is called by the RA.
        Default value: present

  host: (Required) Name/IPAddress of the host.

  path: (Required) Path to the host. 
        For example, "/Datacenter-1/cluster-1".
        
  vswitch:(Required) Name of the vswitch.
        
  type: The type of port group user wants to create.
        Valid values : "VirtualMachine" and "VMkernel"
        Default value: "VirtualMachine"

  vmotion: This is to notify that the vmotion is required or not on the VMkernel port group. 
           This is optional in case of port group of type "virtualMachine".
           Valid values : "Enabled", "Disabled"

  ipsettings: IP settings required on the port group. 
            Valid values : "dhcp", "static"
                         
  ipaddress: This is the ipaddress to be applied on created port group.It is required if the "ipsettings" parameter's value is "static".
        
  subnetmask: This is the subnetmask to be applied on created port group.
              It is required if the "ipsettings" parameter's value is "static".

  traffic_shaping_policy: This is the traffic shaping policy to be applied on port group.
                          Valid values : "Enabled", "Disabled"
                         
  averagebandwidth: This is average bandwidth to be applied on port group.It is used if "traffic_shaping_policy"" is enabled.
                   Default value: 1000 Kbits/sec
        
  peakbandwidth: This is peak bandwidth to be applied on port group.It is used if "traffic_shaping_policy"" is enabled.
                 Default value: 1000 Kbits/sec
                        
  burtsize: This is burst size to be applied on port group.It is used if "traffic_shaping_policy"" is enabled.
            Default value: 1024 Kbytes
                        
  vlanid : vlanId to be set on the portgroup.
           Valid value: 0 to 4095
           Default value: 0 (No vlan)

# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
  esx_portgroup { 'name':
    name => "test25",
    ensure => present,
    type => "VMkernel",
    vmotion => "Disabled",
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
   Examples can be referred in the test directory.
   
   User can provide inputs in data.pp, and apply esx_portgroup.pp for various operations.
   e.g,
   # puppet apply esx_portgroup.pp

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------      
