# Copyright 2015 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class VirtualHardwareMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'VirtualHardware',
        ],
        :memoryMB => LeafData[
          :desc     => "The memory size to assign to the target VM",
          :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
          :munge    => PuppetX::VMware::Mapper::munge_to_i,
        ],
        :numCoresPerSocket => LeafData[
          :desc     => "The number of cores per CPU socket on the target VM",
          :validate => PuppetX::VMware::Mapper::validate_i_ge(1),
          :munge    => PuppetX::VMware::Mapper::munge_to_i,
        ],
        :numCPUs => LeafData[
          :desc        => "The total number of vCPUs on the target VM. numCPUs % numCoresPerSocket should always equal 0",
          :validate    => PuppetX::VMware::Mapper::validate_i_ge(1),
          :munge       => PuppetX::VMware::Mapper::munge_to_i,
          :path_is_now => [:numCPU],
        ],
        :virtualICH7MPresent => LeafData[
          :prop_name  => 'virtual_ich7m_present',
          :desc       => "Does this virtual machine have Virtual Intel I/O Controller Hub 7",
          :valid_enum => [:true, :false],
        ],
        :virtualSMCPresent => LeafData[
          :prop_name  => 'virtual_smc_present',
          :desc       => "Does this virtual machine have System Management Controller",
          :valid_enum => [:true, :false],
        ],
      }

      super
    end
  end
end
