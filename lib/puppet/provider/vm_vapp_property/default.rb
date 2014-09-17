# Copyright (C) 2014 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vm_vapp_property).provide(:vm_vapp_property, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs' vApp Properties."

  def create
   # Puppet.debug "VM => #{vm_name}, Property ID => #{property.id}"
    Puppet.debug "Starting create method"
    resource.eachproperty do |puppetproperty|
      if puppetproperty.to_s != 'ensure' && resource[puppetproperty.to_s]
        case puppetproperty.to_s
        when 'defaultvalue'
          method_name = 'defaultValue'
        when 'classid'
          method_name = 'classId'
        when 'instanceid'
          method_name = 'instanceId'
        when 'userconfigurable'
          method_name = 'userConfigurable'
        else
          method_name = puppetproperty.to_s
        end

        newproperty.method("#{method_name}=").call(resource[puppetproperty.to_s])
      end
    end
    newproperty.key = new_key
    vm.ReconfigVM_Task(:spec => virtualmachineconfigspec(:add)).wait_for_completion
  end
  
  def destroy
    vm.ReconfigVM_Task(:spec => virtualmachineconfigspec(:remove)).wait_for_completion
  end

  def exists?
    property
  end

  def virtualmachineconfigspec(operation)
    spec = {:operation => operation }
    if operation == :remove
      spec['removeKey'] = property_key(property.key)
    else
      spec['info'] = newproperty
    end

    vapppropspec = RbVmomi::VIM::VAppPropertySpec(spec)
    vminfo = [ vapppropspec ]

    @virtualmachineconfigspec = RbVmomi::VIM::VirtualMachineConfigSpec(
      :vAppConfig => RbVmomi::VIM::VmConfigSpec(
        :property => vminfo
      )
    )
  end

  def newproperty
    @newproperty ||= RbVmomi::VIM::VAppPropertyInfo.new
  end

  def id
    property.id
  end

  def id=(v)
    newproperty.id = v
    @update = true
  end

  def label
    property.label
  end

  def label=(v)
    newproperty.label = v
    @update = true
  end

  def category
    property.category
  end

  def category=(v)
    newproperty.category = v
    @update = true
  end

  def classid
    property.classId
  end

  def classid=(v)
    newproperty.classId = v
    @update = true
  end

  def defaultvalue
    property.defaultValue
  end

  def defaultvalue=(v)
    newproperty.defaultValue = v
    @update = true
  end

  def description
    property.description
  end

  def description=(v)
    newproperty.description = v
    @update = true
  end

  def instanceid
    property.instanceId
  end

  def instanceid=(v)
    newproperty.instanceId = v
    @update = true
  end

  def type
    property.type
  end

  def type=(v)
    newproperty.type = v 
    @update = true
  end

  def userconfigurable
    case property.userConfigurable
      when TrueClass then :true
      when FalseClass then :false
    end
  end

  def userconfigurable=(v)
    newproperty.userConfigurable = v
    @update = true
  end

  def value
    property.value
  end

  def value=(v)
    newproperty.value = v
    @update = true
  end

  def flush
    if @update
      newproperty.key = property.key
      vm.ReconfigVM_Task(:spec => virtualmachineconfigspec(:edit)).wait_for_completion
    end
  end

  def property_key (key)
    if key.nil?
      nil
    else 
      RbVmomi::BasicTypes::Int.new key.to_i
    end
  end

  def new_key
    @newkey ||= vm.config.vAppConfig.property[-1].key
    if @newkey.nil?
      @newkey = 0
    else
      @newkey += 1
    end
    property_key @newkey 
  end

  def findvm(folder,vm_name)
    folder.children.each do |f|
      break if @vm_obj
      case f
      when RbVmomi::VIM::Folder
        findvm(f,vm_name)
      when RbVmomi::VIM::VirtualMachine
        @vm_obj = f if f.name == vm_name
      when RbVmomi::VIM::VirtualApp
        f.vm.each do |v|
          if v.name == vm_name
            @vm_obj = f
            break
          end
        end
      else
        puts "unknown child type found: #{f.class}"
        exit
      end
    end
    @vm_obj
  end

  def datacenter(name=resource[:datacenter_name])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{resource[:datacenter_name]}' not found."
  end

  def vm
    @vm ||= findvm(datacenter.vmFolder, resource[:vm_name]) or raise Puppet::Error, "Unable to locate VM with the name '#{resource[:vm_name]}' "
  end

  def findproperty
    vm.config.vAppConfig.property.find {|p| p[:label] == resource[:label] }
  end

  def property
    @property ||= findproperty
  end
end
