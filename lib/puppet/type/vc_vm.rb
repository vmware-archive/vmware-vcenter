# Copyright (C) 2013 VMware, Inc.
require 'pathname'
Puppet::Type.newtype(:vc_vm) do
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet/property/vmware'
  @doc = 'Manage vCenter VMs.'

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
    desc 'The virtual machine name.'
    newvalues(/.+/)
  end

  newparam(:operation) do
    desc 'whether to create a new VM or clone an existing VM.'
    newvalues(:create, :clone)
    defaultto(:create)
  end

  # common parameters required for both operations
  newparam(:datacenter_name) do
    desc 'Name of the datacenter.'
    newvalues(/.+/)
  end

  newparam(:memorymb) do
    desc 'Amount of memory to be assigned to provisioned VM.'
    defaultto(1024)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:numcpu) do
    desc "Number of CPU's assigned to the new Virtual Machine."
    defaultto(1)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:host) do
    desc 'Name of the host.'
  end

  newparam(:target_datastore) do
    desc 'Name of the target datastore.'
  end

  newparam(:diskformat) do
    desc 'Name of the target datastore.'
    newvalues(:thin, :thick)
    defaultto(:thin)
  end

  # parameters for create vm operation
  newparam(:disksize) do
    desc 'Capacity of the virtual disk (in KB).'
    defaultto(4096)
    munge do |value|
      Integer(value)
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
    defaultto('otherGuest')
  end

  newparam(:portgroup) do
    desc 'Name of the port group to which the vNIC is to be attached.'
    dvalue = 'VM Network'
    defaultto(dvalue)
  end

  newparam(:nic_type) do
    desc 'vNIC type to be created.'
    newvalues('E1000', 'VMXNET 3', 'VMXNET 2')
    defaultto('E1000')
  end

  newparam (:nic_count) do
    desc 'Nic Count that needs to be added in the new Virtual Machine. This parameter is required only in case of create'
    defaultto(1)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:scsi_controller_type) do
    desc 'Virtual SCSI controller type for new Virtual Machine''s boot disk.'
    newvalues('BusLogic Parallel', 'LSI Logic SAS', 'LSI Logic Parallel' ,'VMware Paravirtual')
    defaultto(:'LSI Logic SAS')
  end

  # parameters for clone vm operation

  newparam(:goldvm ) do
    desc 'The gold virtual machine name.'
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
    desc 'DNS domain name.'
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
    desc 'Flag for guest customization'
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:guesttype) do
    desc 'Name of Guest OS type of Clone VM.'
    newvalues(:windows, :linux)
    defaultto(:windows)
  end

  # name is already namevar, this should not be used.
  #newparam(:guesthostname) do
  #  desc 'Computer name for provisioned VM.'
  #end

  newparam(:linuxtimezone) do
    desc 'Time zone for Linux guest OS.'
    defaultto('GMT')
    munge do |value|
      value.upcase
    end
  end

  newparam(:windowstimezone) do
    desc 'Time zone for Windows guest OS.'
    dvalue = '035'
    defaultto(dvalue)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:guestwindowsdomain) do
    desc 'Guest domain name for Windows.'
    defaultto('')
  end

  newparam(:guestwindowsdomainadministrator) do
    desc 'Guest domain administrator user name for Windows.'
    defaultto('')
  end

  newparam(:guestwindowsdomainadminpassword) do
    desc 'Guest domain administrator password for Windows.'
    defaultto('')
  end

  newparam(:windowsadminpassword) do
    desc 'Guest administrator password for Windows.'
    defaultto('')
  end

  newparam(:productid) do
    desc 'Product ID for Windows.'
  end

  newparam(:windowsguestowner) do
    desc 'Owner name for Windows.'
    dvalue = 'TestOwner'
    defaultto(dvalue)
  end

  newparam(:windowsguestorgnization) do
    desc 'Organization name for Windows.'
    dvalue = 'TestOrg'
    defaultto(dvalue)
  end

  newparam(:customizationlicensedatamode ) do
    desc 'Flag for guest customization license data mode.'
    newvalues(:perSeat, :perServer)
    defaultto(:perServer)
  end

  newparam(:autologon ) do
    desc 'Flag to determine whether or not the machine automatically logs on as Administrator.'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:autologoncount ) do
    desc 'If the AutoLogon flag is set, then the AutoLogonCount property specifies the number of times the machine should automatically log on as Administrator.'
    defaultto(1)
    munge do |value|
      Integer(value)
    end
  end

  newparam(:autousers ) do
    desc 'This key is valid only if customizationlicensedatamode = perServer. The integer value indicates the number of client licenses purchased for the VirtualCenter server being installed. '
    defaultto(1)
    munge do |value|
      Integer(value)
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
