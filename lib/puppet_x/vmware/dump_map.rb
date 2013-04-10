# Copyright (C) 2013 VMware, Inc.

=begin

This program is used during development to read a
type-specific 'map' and generate code for inclusion in
the corresponding defined type (manifest/*.pp) file.

For each property a line is generated including property
name and key path. For example:

failover_level      => \
  nested_value($spec, ['dasConfig', 'admissionControlPolicy', 'failoverLevel']),
isolation_response  => \
  nested_value($spec, ['dasConfig', 'defaultVmSettings', 'isolationResponse']),
restart_priority    => \
  nested_value($spec, ['dasConfig', 'defaultVmSettings', 'restartPriority']),
failure_interval    => \
  nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'failureInterval']),
max_failures        => \
  nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'maxFailures']),

default_port_config_blocked_inherited   => \
  nested_value($spec, ['defaultPortConfig', 'blocked', 'inherited']),
default_port_config_blocked_value       => \
  nested_value($spec, ['defaultPortConfig', 'blocked', 'value']),

=end

require 'rubygems'
require 'hashdiff'
require 'puppet'
require 'puppet_x/vmware/util'
require 'puppet/property/vmware'

# adapt to puppet version
if Puppet.respond_to? :initialize_settings
  Puppet.initialize_settings 
else
  Puppet.settings
end

# when using puppet enterprise, it will be necessary
# to insure that you are using its included ruby
# for example:
#   PATH=/opt/puppet/bin:$PATH
#
# it also may be necessary to define RUBYLIB so puppet 
# can find the mapper files under development
# for example:
#   RUBYLIB=/etc/puppetlabs/puppet/modules/vcenter/lib:/etc/puppetlabs/puppet/modules/vmware_lib/lib

require 'puppet_x/vmware/mapper'

map_type = 'ClusterConfigSpecExMap'
map_type = 'DVPortgroupConfigSpecMap'
map_type = 'VMwareDVSConfigSpecMap'

map_type = ARGV[0]
puts '=== code for defined type: set puppet properties from input nested hash'
puts "=== for map type #{map_type}"

map = PuppetX::VMware::Mapper.new_map(map_type)

map.leaf_list.each do |leaf|
  path = leaf.path_should
  # puts "#{leaf.prop_name}\t=> nested_value($spec, #{path.inspect}),"
  s = '[' << path[1..-1].reduce("'#{path[0]}'"){|r,e| "#{r}, '#{e}'"} << ']'
  puts "#{leaf.prop_name}\t=> nested_value($spec, #{s}),"
end 

=begin

This code might someday grow up to be able also to write out 
sample input for the defined type (minus values, of course)

Idea is to create output with two elements:
* sortable path to put everything in the right order (and remove duplicates)
* text for sample

=end
