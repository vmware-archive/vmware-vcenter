# Copyright (C) 2013 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class HostVirtualNicSpecMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'HostVirtualNicSpec',
        ],
        :distributedVirtualPort => {
          Node => NodeData[
            :node_type => 'DistributedVirtualSwitchPortConnection',
          ],
          :connectionCookie => LeafData[
            :desc => "Generated from implementation",
          ],
          :portgroupKey => LeafData[
            :desc => "The key of the portgroup",
            :prop_name => :dvportgroupname,
            :requires_siblings => [ :switchUuid ],
          ],
          :portKey => LeafData[
            :desc => "The key of the port",
          ],
          :switchUuid => LeafData[
            :desc => "The UUID of the switch",
            :prop_name => :dvswitchname,
            :requires_siblings => [ :portgroupKey ],
          ],
        },
        :ip => {
          Node => NodeData[
            :node_type => 'HostIpConfig',
          ],
          :dhcp => LeafData[
            :desc => "Use DHCP to configure the nic?",
            :valid_enum => [:true, :false],
          ],
          :ipAddress => LeafData[
            :desc => "IP Address assigned to network adapter",
            :requires_siblings => [ :subnetMask, :dhcp ],
          ],
          :subnetMask => LeafData[
            :desc => "Subnet mask",
            :requires_siblings => [ :ipAddress, :dhcp ],
          ],
        },
        :mac => LeafData[
          :desc => "MAC address of virtual adapter",
        ],
        :mtu => LeafData[
          :desc => "The maximum transmission unit for packets size in bytes for the virtual nic.",
          :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
          :munge => PuppetX::VMware::Mapper::munge_to_i,
        ],
        :portgroup => LeafData[
          :desc => "The Portgroup to which the Vnic connects.  Should only be specified if distributedVirtualPort is not.",
          :prop_name => :standardportgroupname
        ],
        :tsoEnabled => LeafData[
          :desc => "Flag enabling or disabling tcp segmentation offset for a virtual nic."
        ],
      }
      super
    end
  end
end
