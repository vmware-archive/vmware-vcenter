
begin
  require 'puppet/property/vmware'
rescue LoadError => e
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet/property/vmware'
end
