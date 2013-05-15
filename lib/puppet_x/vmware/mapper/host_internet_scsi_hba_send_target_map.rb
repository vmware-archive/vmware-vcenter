# Copyright (C) 2013 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class HostInternetScsiHbaSendTargetMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'HostInternetScsiHbaSendTarget',
        ],
        :address => LeafData[
          :desc => "IP address or name of the storage device",
        ],
        :advancedOptions => LeafData[
          :prop_name => PROP_NAME_IS_FULL_PATH,
          :olio => {
            Puppet::Property::VMware_Array_VIM_Object => {
              :property_option => {
                :type => 'HostInternetScsiHbaParamValue',
                :array_matching => :all,
                :comparison_scope => :array_element,
                :key => [:key],
              },
            },
          },
        ],
        :authenticationProperties => {
        	Node => NodeData[
            :node_type => 'HostInternetScsiHbaAuthenticationProperties',
          ],
          :chapAuthEnabled => LeafData[
          	:prop_name => PROP_NAME_IS_FULL_PATH,
          	:desc => "True if CHAP is currently enabled",
          	:valid_enum => [:true, :false]
          ],
          :chapAuthenticationType => LeafData[
          	:prop_name => PROP_NAME_IS_FULL_PATH,
          	:desc => "The preference for CHAP or non-CHAP protocol if CHAP is enabled"
      	  ],
      	  :chapInherited => LeafData[
      	  	:prop_name => PROP_NAME_IS_FULL_PATH,
      	  	:desc => "CHAP settings are inherited",
      	  	:valid_enum => [:true, :false]
      	  ],
      	  :chapName => LeafData[
      	  	:prop_name => PROP_NAME_IS_FULL_PATH,
      	  	:desc => "The CHAP user name if enabled"
    	  	],
    	  	:chapSecret => LeafData[
      	  	:prop_name => PROP_NAME_IS_FULL_PATH,
      	  	:desc => "The CHAP secret if enabled"
    	  	],
    	  	:mutualChapAuthenticationType => LeafData[
          	:prop_name => PROP_NAME_IS_FULL_PATH,
          	:desc => "The preference for CHAP or non-CHAP protocol if CHAP is enabled"
      	  ],
      	  :mutualChapInherited => LeafData[
      	  	:prop_name => PROP_NAME_IS_FULL_PATH,
      	  	:desc => "Mutual-CHAP settings are inherited",
      	  	:valid_enum => [:true, :false]
    	  	],
    	  	:mutualChapName => LeafData[
          	:prop_name => PROP_NAME_IS_FULL_PATH,
          	:desc => "When Mutual-CHAP is enabled, the user name that target "\
                      "needs to use to authenticate with the initiator"
      	  ],
      	  :mutualChapSecret => LeafData[
          	:prop_name => PROP_NAME_IS_FULL_PATH,
          	:desc => "When Mutual-CHAP is enabled, the secret that target "\
                      "needs to use to authenticate with the initiator"
      	  ]
      	},
      	:digestProperties => {
          Node => NodeData[
            :node_type => 'HostInternetScsiHbaDigestProperties'
          ],
          :dataDigestInherited => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Data digest setting is inherited",
            :valid_enum => [:true, :false]
          ],
          :dataDigestType => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "The data digest preference if data digest is enabled"
          ],
          :headerDigestInherited => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "Header digest setting is inherited",
            :valid_enum => [:true, :false]
          ],
          :headerDigestType => LeafData[
            :prop_name => PROP_NAME_IS_FULL_PATH,
            :desc => "The header digest preference if header digest is enabled"
          ]
        },
        :parent => LeafData[
          :desc => "The device name of the host bus adapter from which "\
                    "settings can be inherited."
        ],
        :port => LeafData[
          :desc => "The TCP port of the storage device. If not specified, the "\
                    "standard default of 3260 is used.",
          :munge => PuppetX::VMware::Mapper::munge_to_i,
        ]
      }
      super
    end
  end
end

