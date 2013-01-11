require 'lib/puppet/provider/vcenter'

require 'set'

require 'pathname' # WORK_AROUND #14073 and #7788
module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
# Puppet.debug "module_lib is #{module_lib} in provider"
require File.join module_lib, 'puppet_x/vmware/util'
require File.join module_lib, 'puppet_x/vmware/mapper'

Puppet::Type.type(:vc_cluster_ha).provide(:vc_cluster_ha, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vCenter cluster's settings for HA (High Availability)."

  clusterConfigSpecExMap ||= PuppetX::VMware::Mapper::ClusterConfigSpecExMap.new

  clusterConfigSpecExMap.leaf_list.each do |leaf|
    define_method(leaf.prop_name) do
      value = PuppetX::VMware::Util::nested_value(configurationEx_is_now, leaf.path_is_now)
      value = :true  if TrueClass  === value
      value = :false if FalseClass === value
      value
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      PuppetX::VMware::Util::nested_value_set(configurationEx_should, leaf.path_should, value)
      properties_received.add leaf.prop_name
      properties_required.merge leaf.requires
    end
  end

  # munge the list of failover hosts returned by the API
  # - convert ManagedObjects to ManagedObjectReferences (mo_ref)
  # - sort array to allow consistent comparisons
  alias get_failover_hosts failover_hosts
  def failover_hosts
    v = get_failover_hosts
    # v = v.map{|host| host._ref} if v.is_a? Array
    # v = v.map{|host| "#{host.name}[#{host._ref}]"} if v.is_a? Array
    v = v.map{|host| host._ref} if v.is_a? Array
    v
  end

  def flush_prep
    # To change some properties, the API requires others that may not 
    # have changed. If not, they must be fetched from the type.
    Puppet.debug "requiring: #{@properties_received.inspect} were received"
    properties_required.subtract properties_received
    unless properties_required.empty?
      Puppet.debug "requiring: #{@properties_required.inspect} are required"
      properties_required.each{|p| self.send "#{p}=".to_sym, @resource[p]}
    end

    # create RbVmomi objects with properties in place of hashes with keys
    Puppet.debug "'is_now' is #{configurationEx_is_now.inspect}'}"
    Puppet.debug "'should' is #{configurationEx_should.inspect}'}"
    configurationEx_object = 
      clusterConfigSpecExMap.objectify configurationEx_should
    Puppet.debug "'object' is #{configurationEx_object.inspect}'}"
    configurationEx_object
  end

  def flush
    clusterConfigSpecEx = flush_prep
    task = cluster.ReconfigureComputeResource_Task(
      :modify => true, 
      :spec => clusterConfigSpecEx
    ).wait_for_completion
  end

  private

  define_method(:clusterConfigSpecExMap) do 
    @clusterConfigSpecExMap ||= clusterConfigSpecExMap
  end

  def properties_received
    @properties_received ||= Set.new
  end

  def properties_required
    @properties_required ||= Set.new
  end

  def configurationEx_is_now
    @configurationEx_is_now ||= 
        clusterConfigSpecExMap.annotate_is_now cluster.configurationEx
  end

  def configurationEx_should
    @configurationEx_should ||= {}
  end

  def cluster
    @cluster ||= locate(@resource[:path], RbVmomi::VIM::ClusterComputeResource)
    Puppet.debug "found cluster: #{@cluster.class} '#{@cluster.name}'"
    @cluster
  end

end
