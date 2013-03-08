require 'rubygems'
require 'hashdiff'
require 'puppet'
require 'puppet_x/vmware/util'
require 'puppet/property/vmware'

Puppet.initialize_settings

require 'puppet_x/vmware/mapper'

map_type = 'ClusterConfigSpecExMap'
map_type = 'VMwareDVSConfigSpecMap'

map = PuppetX::VMware::Mapper.new_map(map_type)

puts '=== code for defined type: set puppet properties from input nested hash'
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

map.leaf_list.each do |leaf|
  indent = ' ' * 4
  leaf.path_should[0..-2].each_with_index do |el, ix|
    puts "#{leaf.path_should[0..ix].inspect}\t#{indent * ix}#{el} => {"
  end
  puts "#{leaf.path_should.inspect}\t#{indent * (leaf.path_should.size - 1)}#{leaf.path_should[-1]}"
end if false

=end
