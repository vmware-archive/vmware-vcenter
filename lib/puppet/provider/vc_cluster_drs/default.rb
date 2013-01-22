provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:vc_cluster_drs).provide(:vc_cluster_drs, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for DRS (Distributed Resource Scheduler). See http://pubs.vmware.com/vsphere-50/topic/com.vmware.wssdk.apiref.doc_50/vim.cluster.ConfigSpecEx.html for detailed information on properties and methods."

  Puppet::Type.type(:vc_cluster_drs).properties.collect{|x| x.name}.each do |prop|
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

  def flush
      Puppet.debug "should is #{should.class} '#{should.inspect}'"
      task = cluster.ReconfigureComputeResource_Task(
          :modify => true, 
          :spec => RbVmomi::VIM.ClusterConfigSpecEx(
              :drsConfig => RbVmomi::VIM.ClusterDrsConfigInfo(should)
          )
      ).wait_for_completion
  end

  private

  def should
    @should ||= {}
  end

  def current
    @current ||= cluster.configurationEx.drsConfig
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource)
  end
end
