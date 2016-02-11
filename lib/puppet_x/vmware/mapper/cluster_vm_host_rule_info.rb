# Copyright (C) 2016 VMware, Inc.
module PuppetX::VMware::Mapper  

  class ClusterVmHostRuleInfo < Map
    def initialize
      @initTree = {
        Node => NodeData[
	  :node_type => 'ClusterVmHostRuleInfo',
        ],
        :enabled => LeafData[
	  :desc => 'Flag to indicate whether or not the rule is enabled. Set this property when you configure the rule.',
	  :valid_enum => [:true, :false]
	],
        :inCompliance => LeafData[
          :desc => 'Flag to indicate whether or not the placement of Virtual Machines is currently in compliance with this rule. The Server does not currently use this property.',
	  :valid_enum => [:true, :false]
        ],
        :mandatory => LeafData[
          :desc => 'Flag to indicate whether compliance with this rule is mandatory or optional. The default value is false (optional).',
	  :valid_enum => [:true, :false]
        ],
        :affineHostGroupName => LeafData[
          :desc => 'Name of the affine host group (ClusterHostGroup.name). The affine host group identifies hosts on which vmGroupName virtual machines can be powered-on. The value of the mandatory property determines how the Server interprets the rule. '
        ],
        :antiAffineHostGroupName => LeafData[
          :desc => 'Name of the anti-affine host group (ClusterHostGroup.name). The anti-affine host group identifies hosts on which vmGroupName virtual machines should not be powered-on. The value of the mandatory property determines how the Server interprets the rule.'
        ],
        :vmGroupName => LeafData[
          :desc => 'Virtual group name (ClusterVmGroup.name). The virtual group may contain one or more virtual machines.'
        ],
      }
     
      super
    end
  end
end
