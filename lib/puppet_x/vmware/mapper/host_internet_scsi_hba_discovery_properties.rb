# Copyright (C) 2013 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class HostInternetScsiHbaDiscoveryPropertiesMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'HostInternetScsiHbaDiscoveryProperties',
        ],
        :iSnsDiscoveryEnabled => LeafData[
          :desc => "True if iSNS is currently enabled",
          :valid_enum => [:true, :false]
        ],
        :iSnsDiscoveryMethod => LeafData[
          :desc => "The iSNS discovery method in use when iSNS is enabled.",
          :valid_enum => ['isnsDhcp', 'isnsSlp', 'isnsStatic']
        ],
        :iSnsHost => LeafData[
          :desc => "For STATIC iSNS, this is the iSNS server address"
        ],
        :sendTargetsDiscoveryEnabled => LeafData[
          :desc => "True if send targets discovery is enabled",
          :valid_enum => [:true, :false]
        ],
        :slpDiscoveryEnabled => LeafData[
          :desc => "True if SLP is enabled",
          :valid_enum => [:true, :false]
        ],
        :slpDiscoveryMethod => LeafData[
          :desc => "The current SLP discovery method when SLP is enabled.",
          :valid_enum => ['slpAutoMulticast', 'slpAutoUnicast', 'slpDhcp', 'slpManual']
        ],
        :slpHost => LeafData[
          :desc => "When the SLP discovery method is set to MANUAL, this property reflects the hostname, and optionally port number of the SLP DA. "
        ],
        :staticTargetDiscoveryEnabled => LeafData[
          :desc => "True if static target discovery is enabled",
          :valid_enum => [:true, :false]
        ]
      }
      super
    end
  end
end
