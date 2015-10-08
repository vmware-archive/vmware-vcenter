#!/opt/puppet/bin/ruby
require 'json'
require 'rbvmomi'
require 'trollop'

opts = Trollop::options do
  opt :server, 'vcenter address', :type => :string, :required => true
  opt :port, 'vcenter port', :default => 443
  opt :username, 'vcenter username', :type => :string, :required => true
  opt :password, 'vcenter password', :type => :string, :default => ENV['PASSWORD']
  opt :timeout, 'command timeout', :default => 240
  opt :community_string, 'dummy value for ASM, not used'
  opt :output, 'output facts to a file', :type => :string, :required => true
end
facts = {}

def collect_inventory(obj)
  hash = {:name => obj.name, :id => obj._ref, :type => obj.class, :attributes => {}, :children => []}
  case obj
    when RbVmomi::VIM::Folder
      obj.children.each { |resource| hash[:children] << collect_inventory(resource) }
    when RbVmomi::VIM::Datacenter
      @datacenter_count += 1
      (obj.hostFolder.children + obj.datastoreFolder.children).each { |resource| hash[:children] << collect_inventory(resource) }
    when RbVmomi::VIM::ClusterComputeResource
      @cluster_count += 1
      obj.host.each { |host| hash[:children] << collect_inventory(host) }
    when RbVmomi::VIM::ComputeResource
      #If ComputeResource but not ClusterComputeResource, it is a standalone host
      hash = collect_inventory(obj.host.first)
    when RbVmomi::VIM::HostSystem
      @host_count += 1
      hash[:attributes] = collect_host_attributes(obj)
      obj.vm.each{ |vm| hash[:children] << collect_inventory(vm)}
    when RbVmomi::VIM::VirtualMachine
      @vm_count += 1
      hash[:attributes] = collect_vm_attributes(obj)
  end
  hash
end

def collect_host_attributes(host)
  attributes = {}
  #For blades, there are 2 service tags.  1 for chassis, and one for the blade itself, and there doesn't seem to be anything distinguishing the 2
  service_tag_array = host.summary.hardware.otherIdentifyingInfo
                         .select{|x| x.identifierType.key=='ServiceTag'}
                         .collect{|x| x.identifierValue}
  attributes[:service_tags] = service_tag_array
  attributes
end

def collect_vm_attributes(vm)
  {:template => vm.summary.config.template}
end

begin
  @datacenter_count = 0
  @cluster_count = 0
  @host_count = 0
  @vm_count = 0

  Timeout.timeout(opts[:timeout]) do
    vim = RbVmomi::VIM.connect(:host=>opts[:server], :password=>opts[:password], :user=> opts[:username], :port=>opts[:port], :insecure=>true)
    name = vim.serviceContent.setting.setting.find{|x| x.key == 'VirtualCenter.InstanceName'}.value
    inventory = collect_inventory(vim.serviceContent.rootFolder).to_json
    facts = {
        :vcenter_name => name,
        :datacenter_count => @datacenter_count.to_s,
        :cluster_count => @cluster_count.to_s,
        :vm_count => @vm_count.to_s,
        :host_count => @host_count.to_s,
        :inventory => inventory
    }.to_json
  end
rescue Timeout::Error
  puts "Timed out trying to gather inventory"
  exit 1
rescue Exception => e
  puts "#{e}\n#{e.backtrace.join("\n")}"
  exit 1
else
  if facts.empty?
    puts 'Could not get updated facts'
    exit 1
  else
    puts 'Successfully gathered inventory.'
    puts JSON.pretty_generate(JSON.parse(facts))
    File.write(opts[:output], facts)
  end
end
