# Copyright (C) 2013 VMware, Inc.
require 'pathname'

vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

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

  newparam(:goldvm ) do
    desc "The gold virtual machine name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid gold Virtual Machine name."
      end
    end
  end

  newparam(:datacenter_name) do
    desc "Name of the datacenter."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter name."
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

  newparam(:memorymb) do
    desc "Amount of memory to be assigned to provisioned VM."
    dvalue = '1024'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
        dvalue.to_i
      else
        value.to_i
      end
    end
  end

  newparam(:dnsdomain) do
    desc "DNS domain name."
  end

  newparam(:numcpu) do
    desc "Number of CPU's assigned to the new Virtual Machine."
    dvalue = '1'
    defaultto(dvalue)
    munge do |value|
      if value.strip.length == 0
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

  newparam(:nicspec) do
    desc "This parameter holds follwoing virtual NICs specification parameter values.+
          ip: Static IP address to the Virtual Machine. If left blank, the module uses the DHCP to set the IP address.+
          subnet: Default subnet mask on the NICs.+
          gateway: Default Gateway on the NIC.+
          dnsserver: DNS servers on the NICs."
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
      if value.strip.length == 0
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
      if value.strip.length == 0
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
      if value.strip.length == 0
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
