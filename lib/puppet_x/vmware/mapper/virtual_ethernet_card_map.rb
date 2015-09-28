# Copyright 2015 VMware, Inc.

require 'set'

module PuppetX::VMware::Mapper

  class VirtualEthernetCardMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'VirtualEthernetCard',
        ],
        :type               => LeafData[
          :desc             => 'Virtual Ethernet Card Type',
          :valid_enum       => [:e1000, :e1000e, :vmxnet2, :vmxnet3]
        ],
        :portgroup          => LeafData[
          :desc             => "The name of the portgroup this adapter is connected on"
        ],
        :addressType        => LeafData[
          :desc             => 'MAC address type',
          :valid_enum       => [:manual, :generated, :assigned]
        ],
        :macAddress         => LeafData[
          :desc             => 'MAC address assigned to the virtual network adapter.'
        ],
        :wakeOnLanEnabled   => LeafData[
          :desc             => 'Indicates whether wake-on-LAN is enabled on this virtual network adapter.',
          :valid_enum       => [:true, :false]
        ],
        :unitNumber         => LeafData[
          :desc             => 'The unit number of this device on its controller'
        ],
        :controllerKey      => LeafData[
          :desc             => 'Object key for the controller object for this device.'
        ],
        :key                => LeafData[
          :desc             => 'Used Internally. A unique key that distinguishes this device from other devices in the same virtual machine.'
        ],
        :deviceInfo         => {
          Node => NodeData[
            :node_type      => 'Description',
          ],
          :summary          => LeafData[
            :desc           => 'Summary description'
          ],
        },
        :connectable        => {
          Node => NodeData[
            :node_type      => 'VirtualDeviceConnectInfo'
          ],
          :allowGuestControl => LeafData[
            :desc            => 'Enables guest control over whether the connectable device is connected.',
            :valid_enum      => [:true, :false]
          ],
          :connected         => LeafData[
            :desc            => 'Indicates whether the device is currently connected. Valid only while the virtual machine is running.',
            :valid_enum      => [:true, :false]
          ],
          :startConnected    => LeafData[
            :desc            => 'Specifies whether or not to connect the device when the virtual machine starts.',
            :valid_enum      => [:true, :false]
          ], 
          :status            => LeafData[
            :desc            => 'Indicates the current status of the connectable device. Valid only while the virtual machine is running.',
            :valid_enum      => [:ok, :recoverableError, :unrecoverableError, :untried]
          ],
        },
      }

      super
    end
  end
end
