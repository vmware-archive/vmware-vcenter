# Copyright (C) 2015 VMware, Inc.
require 'set'

require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
Puppet.debug "module_lib = #{module_lib.inspect}"
Puppet.debug "File.join module_lib, 'puppet/provider/vcenter'  = #{File.join module_lib, 'puppet/provider/vcenter'}"
require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:vc_vm_host_rule).provide(:vc_vm_host_rule, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for VM-Host rules. http://pubs.vmware.com/vsphere-55/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc%2Fvim.cluster.VmHostRuleInfo.html"
  
  ##### begin common provider methods #####
  # besides name, these methods should look exactly the same for all providers
  # ensurable resources will have create, create_message, exist? and destroy

  map ||= PuppetX::VMware::Mapper.new_map('ClusterVmHostRuleInfo')

  def create
    @creating = true
    @create_message ||= []
    map.leaf_list.each do |leaf|
      p = leaf.prop_name
      unless (value = @resource[p]).nil?
        self.send("#{p}=".to_sym, value)
        @create_message << "#{leaf.full_name} => #{value.inspect}"
      end 
    end

  end

  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  define_method(:map) do
    @map ||= map
  end

  map.leaf_list.each do |leaf|
    Puppet.debug "Auto-discovered property [#{leaf.prop_name}] for type [#{self.name}]"

    define_method(leaf.prop_name) do
      value = PuppetX::VMware::Mapper::munge_to_tfsyms.call(
        PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      )
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set(config_should, leaf.path_should, value)
      
      @flush_required = true
    end
  end

  def exists?
    config_is_now
  end

  ##### begin standard provider methods #####
  # these methods should exist in all ensurable providers, but content will diff

  def config_is_now
    @config_is_now ||= (rule ? map.annotate_is_now(rule) : nil)
  end

  def config_should
    @config_should ||= (config_is_now ? config_hash(config_is_now) : {:name => resource[:name]})
  end

  def destroy
    reconfigureComputeResource( :remove )
  end

  def flush
   Puppet.debug "config_is_now is #{config_is_now.inspect}"
   Puppet.debug "config_should is #{config_should.inspect}"
   if @creating
     reconfigureComputeResource( :add )
   elsif @flush_required  
     reconfigureComputeResource( :edit )
   end
  end

  ##### begin private provider specific methods section #####
  # These methods are provider specific and that can be private
  private

  def config_hash(config)
    newHash = {}
    if config
      nodes = []
      map.node_list.each { |node| nodes << node.node_type}
      config.props.each do |k,v|
        if nodes.include? v.class.to_s
          newHash[k] = config_hash v
        else
          newHash[k] = v
        end
      end
      newHash.delete(:backing)
    else
      newHash[:key] = -100
    end
    newHash
  end

  def reconfigureComputeResource(operation)
    rule_spec_info = map.objectify config_should
    case operation
    when :remove
      rule_spec = RbVmomi::VIM::ClusterRuleSpec(
        :operation => operation,
        :removeKey => RbVmomi::BasicTypes::Int.new(rule.key.to_i)
      )
    else
      rule_spec = RbVmomi::VIM::ClusterRuleSpec(
        :operation => operation,
        :info      => rule_spec_info
      )
    end
    spec = RbVmomi::VIM::ClusterConfigSpecEx(:rulesSpec => [rule_spec])
    Puppet.debug "#{self} Reconfiguring cluster '#{cluster.name}' with #{spec.inspect}'"
    cluster.ReconfigureComputeResource_Task(:spec => spec, :modify => true).wait_for_completion
  end

  # returns an array of affinity (or anti-affinity) rules for the cluster
  def rules
    cluster.configurationEx.rule
  end

  def rule
    @rule ||= rules.find {|r| r.name == @resource[:name]}
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource) or raise Puppet::Error, "#{self} cluster not found at path '#{resource[:path]}'."
  end
end
