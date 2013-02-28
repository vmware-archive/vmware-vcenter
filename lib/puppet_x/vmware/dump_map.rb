require 'puppet'
require 'puppet_x/vmware/util'

Puppet.initialize_settings

require 'puppet_x/vmware/mapper'

map_type = 'ClusterConfigSpecExMap'
map_type = 'VMwareDVSConfigSpecMap'

map = PuppetX::VMware::Mapper.new_map(map_type)

map.leaf_list.each do |leaf|
  puts "#{leaf.prop_name}\t#{leaf.path_should.inspect}"
end
