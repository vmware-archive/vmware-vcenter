# Copyright (C) 2014 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

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
    desc 'The resource name'
  end

  newparam(:vm_name) do
    desc "The VM that owns the property"
  end

  newparam(:datacenter_name) do
    desc "The virtual datacenter in which the VM resides"
  end

  newproperty(:category) do
    desc 'A user-visible description the category the property belongs to'
  end

  newproperty(:classId) do
    desc 'Valid values for classId: Any string except any white-space characters'
    validate do |value|
      if value.match(/\s/)
        raise ArgumentError, 'classId cannot contain any white-space characters'
      end
    end
  end

  newproperty(:defaultValue) do 
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

  newproperty(:instanceId) do
    desc 'Valid values for instanceId: Any string except any white-space characters'
    validate do |value|
      if value.match(/\s/)
        raise ArgumentError, 'instanceId cannot contain any white-space characters'
      end
    end
  end

  newproperty(:label) do
    desc "The display name for the property"
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

  newproperty(:userConfigurable) do
    desc 'Whether the property is user-configurable or a system property. This is not used if the type is expression.'
    newvalues(:true, :false)
  end
  
  newproperty(:value) do
    desc 'The value of the field at deployment time. For expressions, this will contain the value that has been computed.'
  end
end
