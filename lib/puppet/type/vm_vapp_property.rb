# Copyright (C) 2014 VMware, Inc.
Puppet::Type.newtype(:vm_vapp_property) do

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:name) do
    desc 'The datacenter, vm name and visible label of the property split by a colon (:). Format dc1:vm1:label'

    munge do |value|
      @resource[:datacenter], @resource[:vm_name], @resource[:label] = value.split(':',3)
    end
  end

  newparam(:vm_name) do
    desc "Set by namevar. Format datacenter:vmname:label"
  end

  newparam(:datacenter) do
    desc "Set by namevar. Format datacenter:vmname:label"
  end

  newproperty(:category) do
    desc 'A user-visible description the category the property belongs to'
  end

  newproperty(:class_id) do
    desc 'Valid values for classId: Any string except any white-space characters'
    validate do |value|
      if value.match(/\s/)
        raise ArgumentError, 'classId cannot contain any white-space characters'
      end
    end
  end

  newproperty(:default_value) do 
    desc 'This either contains the default value of a field (used if value is empty string), or the expression if the type is "expression".'
  end

  newproperty(:description) do
    desc 'Description of the property'
  end

  newproperty(:id) do
    desc 'A name for the property. Valid values for id: Any string except any white-space characters'
    validate do |value|
      if value.match(/\s/)
        raise ArgumentError, 'id cannot contain any white-space characters'
      end
    end
  end

  newproperty(:instance_id) do
    desc 'Valid values for instanceId: Any string except any white-space characters'
    validate do |value|
      if value.match(/\s/)
        raise ArgumentError, 'instanceId cannot contain any white-space characters'
      end
    end
  end

  newproperty(:label) do
    desc "Set by namevar. Format datacenter:vmname:label"
  end

  newproperty(:type) do
    desc 'Describes the valid format of the property'
    newvalues(
      :string, 
      /string\((\d{1,}\.\.|\.\.\d{1,}|\d{1,}\.\.\d{1,})\)/, 
      :int, 
      /int\(\d{1,}\.\.\d{1,}\)/,
      :real, 
      /real\(\d{1,}\.\.\d{1,}\)/,
      :boolean, 
      :password, 
      /password\((\d{1,}\.\.|\.\.\d{1,}|\d{1,}\.\.\d{1,})\)/,
      :ip
    )
  end

  newproperty(:user_configurable) do
    desc 'Whether the property is user-configurable or a system property. This is not used if the type is expression.'
    newvalues(:true, :false)
  end
  
  newproperty(:value) do
    desc 'The value of the field at deployment time. For expressions, this will contain the value that has been computed.'
  end
end
