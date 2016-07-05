# Copyright (C) 2013 VMware, Inc.
require 'pathname' # WORK_AROUND #14073 and #7788

module_lib = Pathname.new(__FILE__).parent.parent.parent
require File.join module_lib, 'puppet_x/vmware/vmware_lib/puppet_x/vmware/util'

require 'set'

module PuppetX
  module VMware
    module Mapper

      # constant for a meaningful unique name that you don't have to invent
      PROP_NAME_IS_FULL_PATH = :PROP_NAME_IS_FULL_PATH

      # constants for use in Leaf Nodes for InheritablePolicy
      InheritablePolicyInherited = :InheritablePolicyInherited
      InheritablePolicyExempt = :InheritablePolicyExempt
      InheritablePolicyValue = :InheritablePolicyValue

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
            :olio,
            :path_is_now,
            :path_should,
            :prop_name,
            :requires,
            :requires_siblings,
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
          @props[:olio] ||= {}
          @props[:requires] ||= []
          @props[:requires_siblings] ||= []

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
              x = @props[:path_should].
                  map{|name| PuppetX::VMware::Util.snakeize name}.
                  join "_"
              x = x.to_sym
            else
              # specified explicitly in map
              @props[:prop_name]
            end
        end

        self.property_access Prop_names
      end

      class Node < MapComponent
        Prop_names = [
            :misc,
            :node_type,
            :node_types,
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
          @props[:misc] ||= Set.new()

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

          # now that it's complete, go through leaf_list 
          # to resolve interdependencies
          requires_for_inheritable_policy
          requires_for_requires_siblings

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

              # If this node is a concrete type, the type is in node.node_type
              # If it's an abstract type,
              #   ABSTRACT  requires the type be the value for a key in data
              #   ABSTRACT2 requires the type be derived from the sole key in data

              if node.node_types
                # the ABSTRACT2 paradigm... avoiding key conflicts among
                # concrete types by pushing concrete type keys down a level
                if \
                    (data.size == 1) &&
                    (the_key = data.keys.first) &&
                      # the 'type' prefix is solely because puppet won't accept 
                      # a hash key starting with an uppercase letter
                    (the_key.to_s =~ /^type([A-Z][A-Za-z0-9_]*)$/) &&
                    (Regexp.last_match.size > 1) &&
                    (node.node_types.include? Regexp.last_match[1].to_sym)
                  # we have a type; pull the data up, deleting the_key
                  node_type = Regexp.last_match[1].to_sym
                  data = data[the_key]
                end
              elsif node.node_type == :ABSTRACT
                node_type = data.delete(node.node_type_key)
              elsif node.node_type
                node_type = node.node_type
              else
                node_type = nil
              end

              if data.empty?
                # data was originally empty, or contained only type information
                parent = PuppetX::VMware::Util::nested_value(obj_tree, node.path_should[0..-2])
                parent.delete(node.path_should[-1])
                Puppet.debug "node #{node.path_should.join('.')}: key and value deleted"
              else
                # if node_type is unknown, there's a problem
                unless node_type
                  if (node.node_type == :ABSTRACT) && node.node_type_key
                    msg = "Input error. vSphere API object type required: " + 
                        "[#{node.path_should.join('.')}.#{node.node_type_key}]"
                  elsif node.node_types # :ABSTRACT2
                    msg = "Input error. vSphere API type information required, one of: "
                    node.node_types.each{|type| msg << "type#{type}; "}
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
            if o = PuppetX::VMware::Util::nested_value(is_now, node.path_is_now)
              type_name = o.class.to_s.split('::').last.to_sym
              if node.node_type == :ABSTRACT2
                type_name = "type#{type_name}".to_sym
                o.props[type_name] = {}.update o.props
              elsif node.node_type == :ABSTRACT
                o[node.node_type_key] = type_name
              end
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

        def requires_for_inheritable_policy
          #
          # path notes for 'inherited' leaf:
          # path[0..-1]                my path
          # path[0..-2]                path to my container, my parent
          # path[0..-3]                path to my container's container,
          #                            my grandparent
          # path[0..-2] + [:sib]       path to my sibling property 'sib',
          #                            which should require me
          # path[0..-3] + [:inherited] path to 'inherited' property that
          #                            is a child of my grandparent (an 
          #                            aunt, say), which I should require
          # 
          @leaf_list.
            # find each leaf of type InheritedPolicyInherited 
            select{|leaf| leaf.misc.include? InheritablePolicyInherited}.
            each  {|leaf_mine|

              # require my 'aunt' inherited property, if there is one
              path_mine = leaf_mine.path_should
              if path_mine.size >= 2 # don't try to back up above root
                path_aunt = path_mine[0..-3] + [:inherited]
                aunt = @leaf_list.find{|l| l.path_should == path_aunt}
                leaf_mine.requires.push aunt.prop_name unless 
                  aunt.nil? or leaf_mine.requires.include? aunt.prop_name
              end

              # add myself as a requirement for each non-exempt sibling
              # and also mark it as InheritablePolicyValue so it will use
              # insyncInheritablePolicyValue -- not modular, but...
              name_mine = leaf_mine.prop_name
              path_prefix_sib = path_mine[0..-2]
              @leaf_list.
                select{|leaf| leaf.path_should[0..-2] == path_prefix_sib}.
                reject{|leaf| leaf.prop_name == name_mine}.
                reject{|sib|  sib.misc.include? InheritablePolicyExempt}.
                tap   {|siblings|  
                  siblings.
                    reject{|sib| sib.requires.include? name_mine}.
                    each  {|sib| sib.requires.push name_mine}
                  siblings.
                    reject{|sib| sib.misc.include? InheritablePolicyValue}.
                    each  {|sib| sib.misc.push InheritablePolicyValue}
                }
            }
        end

        def requires_for_requires_siblings
          # resolve requires_siblings (path-based) to requires (prop_names)
          @leaf_list.
            reject{|leaf| leaf.requires_siblings.empty?}.
            each  {|leaf|
              leaf.requires_siblings.each do |sib|
                sib_path = leaf.path_is_now[0..-2] + [sib]
                sib_leaf = @leaf_list.find{|l| l.path_is_now == sib_path}
                if sib_leaf
                  leaf.requires.push sib_leaf.prop_name.to_sym unless
                    leaf.requires.include? sib_leaf.prop_name.to_sym
                else
                  fail "Not found: sibling #{sib} for '#{leaf.full_name}'"
                end
              end
            }
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
          insyncInheritablePolicyValue is, @resource, :foo
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

      def self.insyncInheritablePolicyValue is, resource, prop_name

        provider = resource.provider
        map = provider.map

        # find the leaf for the value to be insync?'d
        leaf_value = map.leaf_list.find do |leaf|
          leaf.prop_name == prop_name
        end

        # for the corresponding 'inherited' value, generate the path
        path_is_now_inherited = leaf_value.path_is_now[0..-2].dup.push(:inherited)

        # for the corresponding 'inherited' value, find leaf, get prop_name
        prop_name_inherited = map.leaf_list.find do |leaf|
                                leaf.path_is_now == path_is_now_inherited
                              end.prop_name

        # get 'is_now' value for 'inherited' from provider
        is_now_inherited = provider.send "#{prop_name_inherited}".to_sym
        # get 'should' value for 'inherited' from resource
        should_inherited = resource[prop_name_inherited]
        # munge
        is_now_inherited = munge_to_tfsyms.call is_now_inherited
        should_inherited = munge_to_tfsyms.call should_inherited

        case [is_now_inherited, should_inherited]
        # 'should' be inherited, so current value is ignored
        when [:true,  :true]  ; then return false
        when [:false, :true]  ; then return false
        # was inherited, but should be no longer - must supply all values
        when [:true, :false]  ; then return false
        # value is and should be uninherited, so normal insync?
        when [:false, :false] ; then return nil
        else
          return nil if is_now_inherited.nil?
          fail "For InheritedPolicy #{leaf_value.full_name}, "\
            "current '.inherited' is '#{is_now_inherited.inspect}', "\
            "requested '.inherited' is '#{should_inherited.inspect}'"
        end
      end
  
    end
  end
end
