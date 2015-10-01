# Copyright 2015 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class VirtualDiskMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'VirtualDisk',
        ],
        :key           => LeafData[
          :desc          => 'Only used internally when a update or removal to an existing monitor',
        ],
        :controllerKey => LeafData[
          :desc          => 'Object key for the controller object for this device. This property contains the key property value of the controller device object.',
          :prop_name     => 'controller'
        ],
        :capacityInKB => LeafData[
          :desc       => 'Capacity of this virtual disk in bytes. Server will always populate this property. Clients must initialize it when creating a new non -RDM disk or in case they want to change the current capacity of an existing virtual disk, but can omit it otherwise.',
          :prop_name  => 'capacity_in_kb',
          :munge => PuppetX::VMware::Mapper::munge_to_i,
        ],
        :backing      => {
          Node => NodeData[
            :node_type => 'VirtualDeviceFileBackingInfo',
          ],
          :diskMode     => LeafData[
            :desc       => 'The disk persistence mode.',
            :valid_enum => [:persistent, :nonpersistent, :independent_persistent, :independent_nonpersistent],
          ],
          :writeThrough     => LeafData[
            :desc           => 'lag to indicate whether writes should go directly to the file system or should be buffered.',
            :valid_enum     => [:true, :false]
          ],
        },
        :storageIOAllocation => {
          Node => NodeData[
            :node_type => 'StorageIOAllocationInfo',
          ],
          :limit => LeafData[
            :desc  => 'The utilization of a virtual machine will not exceed this limit, even if there are available resources.',
            :munge => PuppetX::VMware::Mapper::munge_to_i,
          ],
          :shares => {
            Node => NodeData[
              :node_type => 'SharesInfo',
            ],
            :level         => LeafData[
              :desc => 'The allocation level. The level is a simplified view of shares. Levels map to a pre-determined set of numeric values for shares. If the shares value does not map to a predefined size, then the level is set as custom. ',
	      :valid_enum => [:normal, :low, :high, :custom]
            ],
            :shares => LeafData[
              :desc => 'The number of shares allocated. Used to determine resource allocation in case of resource contention. This value is only set if level is set to custom. If level is not set to custom, this value is ignored. Therefore, only shares with custom values can be compared.',
              :munge         => PuppetX::VMware::Mapper::munge_to_i,
            ],
          },
        },
      }

      super
    end
  end
end
