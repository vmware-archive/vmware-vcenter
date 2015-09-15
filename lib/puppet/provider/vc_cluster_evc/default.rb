# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_cluster_evc).provide(:vc_cluster_evc, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for EVC (Enhanced Vmotion Compatibility)."

  def evc_mode_key
    (cluster.summary.currentEVCModeKey || 'disabled').to_sym
  end

  def evc_mode_key=(value)
    message = "You must use vCenter client to set EVCMode. " +
        "This software supports verifying a cluster's EVC Mode Key but cannot set it."
    sem = supported_evc_mode_keys
    unless sem.dup.push(:disabled).include? value
      Puppet.warning "Unsupported EVC Mode Key: '#{value}'"
      Puppet.warning "Supported EVC Mode Keys are 'disabled' and cluster-specific values #{sem.map{|key| key.to_s}.inspect}."
    end
    Puppet.warning "Current EVC mode: #{cluster.summary.currentEVCModeKey}"
  end

  private

  def supported_evc_mode_keys
    @keys ||= vim.serviceInstance.capability.supportedEVCMode.map{|evc_mode| evc_mode.key.to_sym}
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource)
  end
end
