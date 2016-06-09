# Copyright (C) 2013 VMware, Inc.
require 'set'
require 'pathname' # WORK_AROUND #14073 and #7788

module_lib = Pathname.new(__FILE__).parent.parent.parent.parent

require File.join module_lib, 'puppet/provider/vcenter'
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

Puppet::Type.type(:vc_affinity).provide(:vc_affinity, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for VM affinity and anti-affinity rules."

  def exists?
    get_rule
  end

  def create
    if resource[:rule_type] == :anti_affinity
      rule_spec_info = RbVmomi::VIM::ClusterAntiAffinityRuleSpec(
        :name     => resource[:name],
        :enabled  => true,
        :vm       => resolve_vms(resource[:vm]),
        :mandatory => true
        )
    else
      rule_spec_info = RbVmomi::VIM::ClusterAffinityRuleSpec(
        :name     => resource[:name],
        :enabled  => true,
        :vm       => resolve_vms(resource[:vm]),
        :mandatory => true
        )
    end
    rule_spec = RbVmomi::VIM::ClusterRuleSpec(
      :operation => :add,
      :info      => rule_spec_info
      )
    spec = RbVmomi::VIM::ClusterConfigSpecEx(:rulesSpec => [rule_spec])
    cluster.ReconfigureComputeResource_Task(:spec => spec, :modify => true).wait_for_completion
  end

  def destroy
    rule_spec = RbVmomi::VIM::ClusterRuleSpec(
      :operation => :remove,
      :removeKey => rule_key
    )
    spec = RbVmomi::VIM::ClusterConfigSpecEx(:rulesSpec => [rule_spec])
    cluster.ReconfigureComputeResource_Task(:spec => spec, :modify => true).wait_for_completion
  end

  private

  # returns an array of affinity (or anti-affinity) rules for the cluster
  def rules
    cluster.configurationEx.rule
  end

  def resolve_vms(vm_array)
    vm_mob_array = []
    vm_array.each do |vm|
      found_vm = find_vm(cluster.resourcePool,vm)
      fail "Could not find virtual machine: #{vm}" unless found_vm
      vm_mob_array.push(found_vm)
    end
    vm_mob_array
  end

  # Find a VM by name in a given array of VM managed objects (cluster.resourcePool.vm)
  def find_vm(rp,vm_name)
    mob_vm = nil
    rp.vm.each do |vm|
      break if ! mob_vm.nil?
      mob_vm = vm if vm.name == vm_name
    end
    if mob_vm.nil?
      rp.resourcePool.each do |child_rp|
        break if ! mob_vm.nil?
        mob_vm = find_vm(child_rp, vm_name)
      end
    end
    mob_vm
  end

  def get_rule
    rules.find {|rule| rule.name == @resource[:name]}
  end

  def rule_key
    rule = get_rule
    if rule.nil?
      nil
    else
      RbVmomi::BasicTypes::Int.new rule.key.to_i
    end
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource)
  end
end

