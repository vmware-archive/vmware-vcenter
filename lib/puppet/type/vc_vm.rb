# Copyright (C) 2013 VMware, Inc.
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

  newproperty(:power_state) do
    desc "Power state of the vm."
    newvalues(:poweredOn, :poweredOff, :reset, :suspend)
  end

  newparam(:name, :namevar => true) do
    desc "The virtual machine name."
    validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid vm name."
      end
    end
  end

  newparam(:goldvm ) do
    desc "The gold virtual machine name."
	validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid gold vm name."
      end
    end
  end

  newparam(:graceful_shutdown) do
    desc "Do the gracefull shut down of vm."
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:datacenter) do
    desc "Name of the datacenter."
	validate do |value|
      if value.strip.length == 0
        raise ArgumentError, "Invalid datacenter name."
      end
    end
  end

  newparam(:memorymb) do
    desc "Amount of memory to be assigned to provisioned VM."
    dvalue = 1024
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
    desc "Number of CPU."
    dvalue = 1
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
    desc "Number of CPU."
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
    dvalue = 035
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
    desc "If the AutoLogon flag is set,	then 
	the AutoLogonCount property specifies the number of times the machine should automatically log on as Administrator."
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
end