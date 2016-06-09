

begin
  require 'puppet_x/puppetlabs/transport/vsphere'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  require File.join module_lib, 'puppet_x/puppetlabs/transport/vsphere'
end
