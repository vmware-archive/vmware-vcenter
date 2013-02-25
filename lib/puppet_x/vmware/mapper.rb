# Copyright (C) 2013 VMware, Inc.
require 'pathname' # WORK_AROUND #14073 and #7788

vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'

module_lib = Pathname.new(__FILE__).parent.parent.parent

module PuppetX
  module VMware
    module Mapper

      PROP_NAME_IS_FULL_PATH = :PROP_NAME_IS_FULL_PATH

      def self.new_map mapname
        mapfile = PuppetX::VMware::Util.snakeize mapname
        require 'pathname'
        file_path = Pathname.new(__FILE__)
        Puppet.debug "require \"#{file_path.parent}/#{file_path.basename '.rb'}/#{mapfile}\""
        require "#{file_path.parent}/#{file_path.basename '.rb'}/#{mapfile}"
        PuppetX::VMware::Mapper::const_get(mapname).new
      rescue Exception => e
        fail "#{self.name}: Error accessing or creating mapper \"#{mapname}\": #{e.message}"
      end

      class MapComponent

        def initialize(input, prop_names)
          # copy input to @props hash
          @props = {}
          input = input.dup
          prop_names.each do |name|
            if input.include? name
              v = input.delete name
              @props[name] =
                  if v.respond_to?(:dup)
                    begin
                      v.dup
                    rescue TypeError
                      # several classes claim to respond_to?(:dup)
                      # but they actually throw a TypeError
                      v
                    end
                  else
                    v
                  end
            end
          end
          unless input.empty?
            fail "#{self.class} doesn't recognize some input: #{input.inspect}"
          end
        end

        private

        def self.property_access prop_names=[]
          define_method(:copy_props) { @props.dup }
          prop_names.each do |name|
            define_method(name) { @props[name] }
          end
          if prop_names.include? :path_should
            define_method(:camel_name) { @props[:path_should][-1] }
            define_method(:full_name) { @props[:path_should].join('.') }
          end
        end
      end

      class Leaf < MapComponent
        Prop_names = [
            :desc,
            :misc,
            :munge,
            :path_is_now,
            :path_should,
            :prop_name,
            :requires,
            :validate,
            :valid_enum,
          ]

        def initialize input
          # copy input to @props hash
          super input, Prop_names

          # check for required values
          fail "#{self.class} doesn't include 'path_should'" unless
            @props[:path_should]
          @props[:misc] ||= []
          @props[:requires] ||= []

          # set defaults and munge
          @props[:path_is_now] ||= @props[:path_should]
            # .dup not necessary because of following map to_sym
          @props[:path_is_now] = @props[:path_is_now].map{|v| v.to_sym}
          @props[:path_should] = @props[:path_should].map{|v| v.to_sym}
          @props[:prop_name] =
            case @props[:prop_name]
            when nil
              # autogenerate using last element in path
              PuppetX::VMware::Util.snakeize(@props[:path_should][-1]).to_sym
            when PROP_NAME_IS_FULL_PATH
              # autogenerate using full path
              @props[:path_should].
                  map{|name| PuppetX::VMware::Util.snakeize name}.
                  join "_"
            else
              # specified explicitly in map
              @props[:prop_name]
            end
        end

        self.property_access Prop_names
      end

      class Node < MapComponent
        Prop_names = [
            :node_type,
            :node_type_key,
            :path_should,
            :path_is_now,
            :url,
          ]

        def initialize input
          # copy input to @props hash
          super input, Prop_names

          # check for required values
          fail "#{self.class} doesn't include 'node_type'" unless
            @props[:node_type]

          # set defaults and munge
          @props[:path_is_now] ||= @props[:path_should]
            # .dup not necessary because of following map to_sym
          @props[:path_is_now] = @props[:path_is_now].map{|v| v.to_sym}
          @props[:path_should] = @props[:path_should].map{|v| v.to_sym}

          @props[:node_type_key] ||= :vsphereType if
            @props[:node_type] == :ABSTRACT
        end

        def path_is_now_to_type
          self.path_is_now.dup << self.node_type_key
        end

        self.property_access Prop_names
      end

      # in effect, these are labels for distinguishing hash
      # values that specify Leaf or Node initialization from
      # hash values that may be roots of trees
      class LeafData < Hash
      end
      class NodeData < Hash
      end

      class Map
        # abstract class 
        # - concrete classes contain initialization data
        # - this class contains methods
        #
        def initialize
          # @initTree is defined in subclasses...
          @leaf_list = []
          @node_list = []

          # walk down the initTree and find the leaves
          walk_down @initTree, [], @leaf_list, @node_list
        end

        attr_reader :leaf_list, :node_list

        def objectify should
          obj_tree = Marshal.load(Marshal.dump(should))
          # Step through the node list, which is in bottom-up sequence.
          # If data for a vSphere object are found in 'should',
          # create the object and replace the data with the object.
          @node_list.each do |node|
            node = node.dup
            Puppet.debug "node #{node.path_should.join('.')}: checking #{node.inspect}"
            data = PuppetX::VMware::Util::nested_value(obj_tree, node.path_should)
            if data
              Puppet.debug "node #{node.path_should.join('.')}: found #{data.inspect}"

              # If this node is a concrete type, the type is in the node.
              # If it's an abstract type, the type must be in a subkey.
              node_type = node.node_type
              node_type = data.delete(node.node_type_key) if node_type == :ABSTRACT

              if data.empty?
                # data was originally empty, or contained only type information
                parent = PuppetX::VMware::Util::nested_value(obj_tree, node.path_should[0..-2])
                parent.delete(node.path_should[-1])
                Puppet.debug "node #{node.path_should.join('.')}: key and value deleted"
              else
                unless node_type
                  if (node.node_type == :ABSTRACT) && node.node_type_key
                    msg = "Input error. vSphere API object type required: " + 
                        "[#{node.path_should.join('.')}.#{node.node_type_key}]"
                  else
                    # neither node_type nor node_type_key found in initTree
                    msg = "Internal error. Type unknown for vSphere API object " +
                        "at [#{node.path_should.join('.')}] type unknown."
                  end
                  fail msg
                end

                begin
                  vso = RbVmomi::VIM.const_get(node_type).new data
                  Puppet.debug "node #{node.path_should.join('.')}: created #{vso.inspect}"
                rescue RuntimeError => e
                  # Check for invalid properties that can occur with abstract types.
                  # See for example ClusterDasAdmissionControlPolicy at
                  # http://pubs.vmware.com/vsphere-51/topic/
                  # com.vmware.wssdk.apiref.doc/
                  # vim.cluster.DasAdmissionControlPolicy.html
                  r = e.message.match(/unexpected property name (.*)/)
                  if r && r[1]
                    name = r[1]
                    msg = "Property [#{node.path_should.join('.')}.#{name}] " +
                        "incompatible with type '#{node_type}'"
                    fail msg
                  else
                    fail e.message
                  end
                end

                # store the object in the tree in place of the data hash
                if node.path_should.empty?
                  obj_tree = vso
                else
                  PuppetX::VMware::Util::nested_value_set(obj_tree, node.path_should, vso)
                end
              end

            end
          end
          obj_tree
        end

        def annotate_is_now is_now
          # for each Node representing an abstract type, annotate
          # the is_now tree to include the current :vsphereType
          @node_list.each do |node|
            if (node.node_type == :ABSTRACT) and
                o = PuppetX::VMware::Util::nested_value(is_now, node.path_is_now)
              o[node.node_type_key] = o.class.to_s.split('::').last.to_sym
            end
          end
          is_now
        end

        private

        def walk_down(hash, key_path, leaf_list, node_list)
          # recursive depth-first tree walk
          # if val is a Hash:
          #   * key_path.push key
          #   * recurse
          #   * key_path.pop
          # if val is LeafData:
          #   * add :path_should => key_path to val
          #   * leaf_list.push Leaf.new(val)
          # if val is Node:
          #   * add :path_should => key_path to val
          #   * node_list.push Node.new(val)
          # else:
          #   * exception
          hash.each_pair do |key, value|
            case value
            when LeafData, NodeData
              true
            when Hash
              key_path.push key
              walk_down value, key_path, leaf_list, node_list
              key_path.pop
            else
              fail "Unexpected value: #{value.class} '#{value.inspect}'"
            end
          end
          hash.each_pair do |key, value|
            case value
            when LeafData
              value[:path_should] = key_path.dup << key
              leaf_list.push(Leaf.new value)
            when NodeData
              value[:path_should] = key_path.dup
              node_list.push(Node.new value)
            end
          end
        end
      end

=begin

This is a set of tiny utilities for defining validation and munging
routines in the input tree for Map. Some are simply static blocks wrapped
in Proc, while others allow tailoring the block to specific cases.

=end

      def self.munge_to_i
        Proc.new {|v| v.to_i}
      end

      def self.munge_to_tfsyms
        Proc.new do |v|
          case v
          when FalseClass then :false
          when TrueClass  then :true
          else v
          end
        end
      end

      def self.munge_to_sym
        Proc.new do |v|
          v.to_sym if String === v
        end
      end

      def self.validate_i_ge(low)
        Proc.new do |v|
          v = Integer v
          fail "value #{v} not greater than nor equal to #{low}" unless low <= v
        end
      end

      def self.validate_i_le(high)
        Proc.new do |v|
          v = Integer v
          fail "value #{v} not less than nor equal to #{high}" unless v <= high
        end
      end

      def self.validate_i_in(range)
        Proc.new do |v|
          v = Integer v
          fail "value #{v} not in '#{range.inspect}'" unless range.include? v
        end
      end

=begin

This is a version of insync? for InheritablePolicy 'value'
properties. It looks at the current (is_now) and desired (should)
values of 'inheritable' (finding it at the same level of nesting)
to determine whether the property of interest should be considered
to be 'in sync'. If that can't be determined, the calling routine
should call the normal insync for the property's class.

Here's what usage looks like in the type:

  newproperty(:foo, ...) do
    :
    def insync?(is)
      v = PuppetX::VMware::Mapper.
          insyncInheritablePolicyValue is, @resource, is_now_map, :foo
      v = super(is) if v.nil?
      v
    end
    :
  end

XXX TODO fix this to return a block, to directly call super(is)
XXX TODO fix this to return a block, to directly use @resource
XXX TODO fix this to hold prop_name in a closure, so the caller 
         doesn't have to fool around with eval and interpolation
         when automatically generating newproperty

=end

      # flag for use in maps
      InheritablePolicyValue = :InheritablePolicyValue

      def self.insyncInheritablePolicyValue is, resource, is_now_map, prop_name
        # find the leaf for the value to be insync?'d
        leaf_value = is_now_map.leaf_list.select do |leaf|
          leaf[:prop_name] == prop_name
        end

        # for the corresponding 'inherited' value, find the leaf and the prop_name
        path_is_now_inherited = leaf_value[:path_is_now][0..-2].dup.push(:inherited)
        leaf_inherited = is_now_map.leaf_list.select do |leaf|
          leaf[:path_is_now] == path_is_now_inherited
        end
        prop_name_inherited = leaf_inherited[:prop_name]

        # get 'is_now' value for 'inherited' from map; munge
        is_now_inherited = munge_to_tfsums.call(
            nested_value(is_now_map, path_is_now_inherited))
        # get 'should' value for 'inherited' from resource; munge
        should_inherited = munge_to_tfsyms.call(resource[prop_name_inherited])

        case [is_now_inherited, should_inherited]
        # 'should' be inherited, so input value is ignored
        when [:true, :true]   ; then return true
        # 'should' be inherited, so input value is ignored
        when [:false, :true]  ; then return true
        # was inherited, but should be no longer - must supply all values
        when [:true, :false]  ; then return false
        # value is and should be uninherited, so normal insync?
        when [:false, :false] ; then return nil
        else
          fail "For inherited policy value #{}, "\
            "current 'inherited' is '#{is_now_inherited.inspect}', "\
            "request 'inherited' is '#{should_inherited.inspect}'"
        end
      end
  
    end
  end
end
