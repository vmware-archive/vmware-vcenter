# Copyright (C) 2013 VMware, Inc.
require 'pathname'
begin
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
if !vmware_module.nil?
  require File.join vmware_module.path, 'lib/puppet/property/vmware' 
end
end
Puppet::Type.newtype(:vc_vm) do
  @doc = "Manage vCenter VMs."

  ensurable do
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc "The virtual machine name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid Virtual Machine name."
      end
    end
  end

  newparam(:operation ) do
    desc "Operation name whether user wants to create a new Virtual Machine or wants to clone a new Virtual Machine from existing one."
    newvalues(:create, :clone)
    defaultto(:create)
  end

  # common parameters required for both operations
  newparam(:datacenter_name) do
    desc "Name of the datacenter."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter name."
      end
    end
  end

  newparam(:memorymb) do
    desc "Amount of memory to be assigned to provisioned VM."
    dvalue = '1024'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:numcpu) do
    desc "Number of CPU's assigned to the new Virtual Machine."
    dvalue = '1'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:cluster) do
    desc "Name of the cluster."
  end

  newparam(:host) do
    desc "Name of the host."
  end

  newparam(:target_datastore) do
    desc "Name of the target datastore."
  end

  newparam(:diskformat) do
    desc "Name of the target datastore."
    newvalues(:thin, :thick)
    defaultto(:thin)
  end

  # parameters for create vm operation
  newparam(:disksize) do
    desc "Capacity of the virtual disk (in KB)."
    dvalue = '4096'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:memory_hot_add_enabled) do
    desc 'Indicates whether or not memory can be added to the virtual machine while it is running'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:cpu_hot_add_enabled) do
    desc 'Indicates whether or not cpu can be added to the virtual machine while it is running'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:guestid) do
    desc 'Guest operating system identifier. User can get the guestid from following url +
    http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fvim.vm.GuestOsDescriptor.GuestOsIdentifier.html'
    dvalue = 'otherGuest'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue.to_s
      else
        value.to_s
      end
    end
  end

  newparam(:portgroup) do
    desc "Name of the port group to which the vNIC is to be attached."
    dvalue = 'VM Network'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue.to_s
      else
        value.to_s
      end
    end
  end

  newparam(:nic_type) do
    desc "vNIC type to be created."
    newvalues(:"VMXNET 2", :E1000, :"VMXNET 3")
    defaultto(:E1000)
  end

  newparam (:nic_count) do
    desc "Nic Count that needs to be added in the new Virtual Machine. This parameter is required only in case of create"
    dvalue = '1'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end
  
  newparam(:scsi_controller_type) do
    desc "Virtual SCSI controller type for new Virtual Machine's boot disk."
    newvalues(:"BusLogic Parallel", :"LSI Logic SAS", :"LSI Logic Parallel" ,:"VMware Paravirtual")
    defaultto(:"LSI Logic SAS")
  end

  # parameters for clone vm operation

  newparam(:goldvm ) do
    desc "The gold virtual machine name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid gold Virtual Machine name."
      end
    end
  end

  newparam(:goldvm_datacenter) do
    desc "Name of the gold vm datacenter."
    defaultto('')
    munge do |value|
      if value.strip.length == 0
        value = @resource[:datacenter_name]
      else
        value
      end
    end
  end

  newparam(:dnsdomain) do
    desc "DNS domain name."
  end

  newparam(:nicspec) do
    desc "This parameter holds follwoing virtual NICs specification parameter values.+
            ip: Static IP address to the Virtual Machine. If left blank, the module uses the DHCP to set the IP address.+
            subnet: Default subnet mask on the NICs.+
            gateway: Default Gateway on the NIC.+
            dnsserver: DNS servers on the NICs."
  end

  # Guest Customization params
  newparam(:guestcustomization ) do
    desc "Flag for guest customization"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:guesttype) do
    desc "Name of Guest OS type of Clone VM."
    newvalues(:windows, :linux)
    defaultto(:windows)
  end

  newparam(:guesthostname) do
    desc "Computer name for provisioned VM."
  end

  newparam(:linuxtimezone) do
    desc "Time zone for Linux guest OS."
    dvalue = "EST"
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue.upcase
      else
        value.upcase
      end
    end
  end

  newparam(:windowstimezone) do
    desc "Time zone for Windows guest OS."
    dvalue = '035'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:guestwindowsdomain) do
    desc "Guest domain name for Windows."
    dvalue = ''
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue
      else
        value
      end
    end
  end

  newparam(:guestwindowsdomainadministrator) do
    desc "Guest domain administrator user name for Windows."
    dvalue = ''
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue
      else
        value
      end
    end
  end

  newparam(:guestwindowsdomainadminpassword) do
    desc "Guest domain administrator password for Windows."
    dvalue = ''
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue
      else
        value
      end
    end
  end

  newparam(:windowsadminpassword) do
    desc "Guest administrator password for Windows."
    dvalue = ''
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue
      else
        value
      end
    end
  end

  newparam(:windowsguestowner) do
    desc "Onwer name for Windows."
    dvalue = 'TestOwner'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue
      else
        value
      end
    end
  end

  newparam(:productid) do
    desc "Product ID for Windows."
  end

  newparam(:windowsguestorgnization) do
    desc "Organization name for Windows."
    dvalue = 'TestOrg'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue
      else
        value
      end
    end
  end

  newparam(:customizationlicensedatamode ) do
    desc "Flag for guest customization license data mode."
    newvalues(:perSeat, :perServer)
    defaultto(:perServer)
  end

  newparam(:autologon ) do
    desc "Flag to determine whether or not the machine automatically logs on as Administrator."
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:autologoncount ) do
    desc "If the AutoLogon flag is set, then the AutoLogonCount property specifies the number of times the machine should automatically log on as Administrator."
    dvalue = '1'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:autousers ) do
    desc "This key is valid only if customizationlicensedatamode = perServer. The integer value indicates the number of client licenses purchased for the VirtualCenter server being installed. "
    dvalue = '1'
    defaultto(dvalue)
    munge do |value|
      if value.to_s.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:graceful_shutdown) do
    desc 'Perform a graceful shutdown if possible.  This parameter has no effect unless :power_state is set to :poweredOff'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:power_state) do
    desc 'set the powerstate for the vm to either poweredOn/poweredOff/reset/suspended, for poweredOff, if tools is running a shutdownGuest will be issued, otherwise powerOffVM_TASK'
    newvalues(:poweredOn, :poweredOff, :reset, :suspended)
  end

  #autorequire(:vc_folder) do
  #  Pathname.new(self[:path]).parent.to_s
  #end
end
