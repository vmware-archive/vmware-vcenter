# Copyright (C) 2014 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vm_vapp_property).provide(:vm_vapp_property, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs' vApp Properties."

  Puppet::Type.type(:vm_vapp_property).properties.collect{|x| x.name}.each do |prop|
    camel_prop = PuppetX::VMware::Util.camelize(prop, :lower).to_sym

    define_method(prop) do
      value = current[camel_prop]
      case value
      when TrueClass  then :true
      when FalseClass then :false
      else value
      end
    end

    define_method("#{prop}=") do |value|
      @update = true
      newproperty[camel_prop] = value
    end
  end

  def create
    Puppet.debug "Starting create method for #{resource}"
    resource.eachproperty do |puppetproperty|
      puppetproperty = puppetproperty.to_s
      if puppetproperty != 'ensure' && resource[puppetproperty]
        camel_prop = PuppetX::VMware::Util.camelize(puppetproperty, :lower).to_sym
        newproperty[camel_prop] = resource[puppetproperty]
      end
    end
    newproperty.key = new_key
    vm.ReconfigVM_Task(
        :spec => virtualMachineConfigSpec(
            :add
        )
    ).wait_for_completion
  end
  
  def destroy
    Puppet.debug "Starting destroy method for #{resource}"
    vm.ReconfigVM_Task(
        :spec => virtualMachineConfigSpec(
            :remove
        )
    ).wait_for_completion
  end

  def exists?
    current
  end

  def virtualMachineConfigSpec(operation)
    spec = {:operation => operation }
    if operation == :remove
      spec['removeKey'] = property_key(current.key)
    else
      spec['info'] = newproperty
    end

    vappPropertySpec = RbVmomi::VIM::VAppPropertySpec(spec)
    vappPropertyInfo = [ vappPropertySpec ]

    @virtualMachineConfigSpec = RbVmomi::VIM::VirtualMachineConfigSpec(
      :vAppConfig => RbVmomi::VIM::VmConfigSpec(
        :property => vappPropertyInfo
      )
    )
  end

  def newproperty
    @newproperty ||= RbVmomi::VIM::VAppPropertyInfo.new
  end

  def flush
    if @update
      newproperty.key = current.key
      vm.ReconfigVM_Task(
       :spec => virtualMachineConfigSpec(
         :edit
        )
      ).wait_for_completion
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
    keys = []
    vm.config.vAppConfig.property.each do |p|
      keys.push( p.key )
    end
    
    if keys.max
      newkey = keys.max + 1
    else
      newkey = 0
    end

    property_key newkey
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

  def datacenter(name=resource[:datacenter])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{resource[:datacenter]}' not found."
  end

  def vm
    @vm ||= findvm(datacenter.vmFolder, resource[:vm_name]) or raise Puppet::Error, "Unable to locate VM with the name '#{resource[:vm_name]}' "
  end

  def findproperty
    vm.config.vAppConfig.property.find {|p| p[:label] == resource[:label] }
  end

  def current
    @current ||= findproperty
  end

end
