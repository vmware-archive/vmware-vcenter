#!/opt/puppet/bin/ruby
require "json"
require "rbvmomi"
require_relative "../lib/puppet_x/puppetlabs/transport/rbvmomi_patch" # Use patched library to workaround rbvmomi issues
require "trollop"

opts = Trollop::options do
  opt :server, "ESX or VC IP address", :type => :string, :required => true
  opt :port, "port", :default => 443
  opt :username, "username", :type => :string, :required => true
  opt :password, "password", :type => :string, :default => ENV["PASSWORD"]
  opt :timeout, "command timeout", :default => 20
  opt :output, "output facts to a file", :type => :string, :required => true
  opt :credential_id, 'dummy value for ASM, not used'
  opt :host_ip, "ESX host IP address (only needed for VC connections)", :type => :string
end

def collect_esx_installed_packages(host)
  host.esxcli.software.vib.get.map { |o| o.props.reject { |k| k == :dynamicProperty} }
end

def collect_esx_facts(vim, host_ip)
  puts "Fetching ESX facts for %s" % host_ip

  host = vim.root.findByIp(host_ip, RbVmomi::VIM::HostSystem)

  host = vim.root.findByDnsName(host_ip, RbVmomi::VIM::HostSystem) unless host

  raise "Host '%s' not found" % host_ip if host.nil?

  hash = {:name => host.name, :id => host._ref, :type => host.class}
  hash[:esx_version] = host.config.product.version
  hash[:installed_packages] = collect_esx_installed_packages(host).to_json

  hash
end

begin
  Timeout.timeout(opts[:timeout]) do
    vim = RbVmomi::VIM.connect(:host=>opts[:server], :password=>opts[:password], :user=> opts[:username], :port=>opts[:port], :insecure=>true)

    host_ip = opts[:host_ip] ? opts[:host_ip] : opts[:server]
    facts = collect_esx_facts(vim, host_ip).to_json

    vim.close if vim # close open connection

    puts "Fetched ESX inventory for %s" % host_ip
    puts JSON.pretty_generate(JSON.parse(facts))

    File.write(opts[:output], facts)
  end
rescue
  puts "Error getting ESX software inventory %s: %s\nBacktrace: %s" % [$!.class, $!.message, $!.backtrace.join("\n\t")]
  exit 1
end
