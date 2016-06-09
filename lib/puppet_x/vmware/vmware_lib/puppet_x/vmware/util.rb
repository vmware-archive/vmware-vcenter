begin
  require 'puppet_x/vmware/util'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
end
