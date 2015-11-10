# Copyright (C) 2014 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vm_tools_config).provide(:vm_tools_config, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter VMs' Tools Config."

  Puppet::Type.type(:vm_tools_config).properties.collect{|x| x.name}.each do |prop|
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
      should[camel_prop] = value
    end
  end

  def exists?
    current
  end

  def flush
      Puppet.debug "should is #{should.class} '#{should.inspect}'"
      task = vm.ReconfigVM_Task(
       :spec => RbVmomi::VIM::VirtualMachineConfigSpec(
          :tools => RbVmomi::VIM::ToolsConfigInfo(should)
        )
      ).wait_for_completion
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

  def current
    @current ||= vm.config.tools
  end

  def should
    @should ||= {}
  end

end
