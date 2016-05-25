#!/opt/puppet/bin/ruby
require 'json'
require 'rbvmomi'
require 'trollop'

opts = Trollop::options do
  opt :server, "ESX address", :type => :string, :required => true
  opt :port, "ESX port", :default => 443
  opt :username, "ESX username", :type => :string, :required => true
  opt :password, "ESX password", :type => :string, :default => ENV["PASSWORD"]
  opt :timeout, "command timeout", :default => 240
  opt :output, "output facts to a file", :type => :string, :required => true
  opt :credential_id, 'dummy value for ASM, not used'
end
facts = {}

def collect_esx_installed_packages(host)
  host.esxcli.software.vib.get.map { |o| o.props.reject { |k| k == :dynamicProperty} }
end

def collect_esx_facts(vim)
  # Traverse to host object
  dc = vim.serviceInstance.find_datacenter
  host = dc.hostFolder.children.first.host.first
  hash = {:name => host.name, :id => host._ref, :type => host.class}
  hash[:installed_packages] = collect_esx_installed_packages(host).to_json
  hash
end

begin
  Timeout.timeout(opts[:timeout]) do
    vim = RbVmomi::VIM.connect(:host=>opts[:server], :password=>opts[:password], :user=> opts[:username], :port=>opts[:port], :insecure=>true)
    facts = collect_esx_facts(vim).to_json
    vim.close if vim # close open connection

    if facts.empty?
      puts "Could not get updated facts"
      exit 1
    else
      puts "Successfully gathered inventory."
      puts JSON.pretty_generate(JSON.parse(facts))
      File.write(opts[:output], facts)
    end
  end
rescue Exception => e
  puts "Error gathering ESX software inventory: #{e.class}:#{e.message}"
  exit 1
end
