#
# Wrapper to load the transport library from vmware_lib

begin
  require 'puppet_x/puppetlabs/transport'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet_x/puppetlabs/transport'
end
