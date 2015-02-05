# Copyright (C) 2015 VMware, Inc.
module PuppetX::VMware::Mapper  

  class IpPoolMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
	  :node_type => 'IpPool',
        ],
        :allocatedIpv4Addresses => LeafData[
	  :desc => 'The number of allocated IPv4 addresses',
	],
        :allocatedIpv6Addresses => LeafData[
	  :desc => 'The number of allocated IPv6 addresses',
	],
        :availableIpv4Addresses => LeafData[
	  :desc => 'The number of IPv4 addresses available for allocation',
	],
        :availableIpv6Addresses => LeafData[
	  :desc => 'The number of IPv6 addresses available for allocation',
	],
        :dnsDomain => LeafData[
	  :desc => 'DNS Domain. For example, vmware.com. This can be an empty string if no domain is configured',
	],
        :dnsSearchPath => LeafData[
	  :desc => 'DNS Search Path. For example, eng.vmware.com;vmware.com',
	],
        :hostPrefix => LeafData[
	  :desc => 'Prefix for hostnames',
	],
        :httpProxy => LeafData[
	  :desc => 'The HTTP proxy to use on this network, e.g., :',
	],
        :ipv4Config => {
	  Node => NodeData[
            :node_type => 'IpPoolIpPoolConfigInfo',
          ],
	  :dhcpServerAvailable => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Whether a DHCP server is available on this network',
	    :valid_enum => [:true, :false]
	  ],
	  :dns => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'DNS servers. For example: ["10.20.0.1", "10.20.0.2"]',
	    :olio => {
	      Puppet::Property::VMware_Array => {
	        :property_option => {
	    	  :inclusive => :true,
		  :preserve  => :false,	
  	        },
	      },
	    },
	  ],
	  :gateway => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Gateway. This can be an empty string - if no gateway is configured. For example: 192.168.5.1',
	  ],
	  :ipPoolEnabled => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'IP addresses can only be allocated from the range if the IP pool is enabled',
	    :valid_enum => [:true, :false]
	  ],
	  :netmask => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Netmask. For example: 255.255.255.0',
	  ],
	  :range => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'IP range. This is specified as a set of ranges separated with commas. One range is given by a start address, a hash (#), and the length of the range. For example: 192.0.2.235 # 20 is the IPv4 range from 192.0.2.235 to 192.0.2.254',
	  ],
	  :subnetAddress => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Address of the subnet. For example: 192.168.5.0',
	  ],
	},
        :ipv6Config => {
	  Node => NodeData[
            :node_type => 'IpPoolIpPoolConfigInfo',
          ],
	  :dhcpServerAvailable => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Whether a DHCP server is available on this network',
	    :valid_enum => [:true, :false]
	  ],
	  :dns => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'DNS servers. For example: ["2001:0db8:85a3::0370:7334", "2001:0db8:85a3::0370:7335"]',
	    :olio => {
	      Puppet::Property::VMware_Array => {
	        :property_option => {
	    	  :inclusive => :true,
		  :preserve  => :false,	
  	        },
	      },
	    },
	  ],
	  :gateway => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Gateway. This can be an empty string - if no gateway is configured. For example: 2001:0db8:85a3::1',
	  ],
	  :ipPoolEnabled => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'IP addresses can only be allocated from the range if the IP pool is enabled',
	    :valid_enum => [:true, :false]
	  ],
	  :netmask => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Netmask. For example: ffff:ffff:ffff::',
	  ],
	  :range => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'IP range. This is specified as a set of ranges separated with commas. One range is given by a start address, a hash (#), and the length of the range. For example: 2001::7334 # 20 is the IPv6 range from 2001::7334 to 2001::7347',
	  ],
	  :subnetAddress => LeafData[
	    :prop_name => PROP_NAME_IS_FULL_PATH,
	    :desc => 'Address of the subnet. For example: 2001:0db8:85a3::',
	  ],
	},
        :networkAssociation => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
	  :olio => {
	    Puppet::Property::VMware_Array_VIM_Object => {
	      :property_option => {
		:type => 'IpPoolAssociation',
		:array_matching => :all,
   		:comparison_scope => :array,
                :sort_array => true,
	  	:key => :networkName,
  	      },
	    },
          },
        ],
        :name => LeafData[
	  :desc => 'Pool name. The pool name must be unique within the datacenter.',
	],
      }
     
      super
    end
  end
end
