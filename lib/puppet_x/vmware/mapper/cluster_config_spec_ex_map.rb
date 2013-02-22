# Copyright (C) 2013 VMware, Inc.
module PuppetX::VMware::Mapper

  class ClusterConfigSpecExMap < Map
    def initialize
      @initTree = {
        Node => NodeData[
          :node_type => 'ClusterConfigSpecEx',
        ],
        :dasConfig => {
          Node => NodeData[
            :node_type => 'ClusterDasConfigInfo',
          ],
          :enabled => LeafData[
            :prop_name => :das_config_enabled,
            :desc => "Is HA enabled? true or false",
            :valid_enum => [:true, :false],
          ],
          :admissionControlEnabled => LeafData[
            :desc => "Is admission control enabled? true or false",
            :valid_enum => [:true, :false],
          ],
          :admissionControlPolicy => {
            Node => NodeData[
              :node_type => :ABSTRACT
            ],
            :vsphereType => LeafData[
              :prop_name => :admission_control_policy_type,
              :valid_enum => [
                :ClusterFailoverHostAdmissionControlPolicy,
                :ClusterFailoverLevelAdmissionControlPolicy,
                :ClusterFailoverResourcesAdmissionControlPolicy,
              ],
            ],
            :failoverHosts => LeafData[
              :misc => [Array],
              :requires => [:admission_control_policy_type],
            ],
            :failoverLevel => LeafData[
              :desc => \
                "Number of host failures that should be tolerated, "\
                "still guaranteeing sufficient resources to restart "\
                "virtual machines on available hosts. ",
              :validate => PuppetX::VMware::Mapper::validate_i_ge(0),
              :munge => PuppetX::VMware::Mapper::munge_to_i,
              :requires => [:admission_control_policy_type],
            ],
            :cpuFailoverResourcesPercent => LeafData[
              :valid_enum => 1..100,
              :munge => PuppetX::VMware::Mapper::munge_to_i,
              :requires => [:admission_control_policy_type, :memory_failover_resources_percent],
            ],
            :memoryFailoverResourcesPercent => LeafData[
              :valid_enum => 1..100,
              :munge => PuppetX::VMware::Mapper::munge_to_i,
              :requires => [:admission_control_policy_type, :cpu_failover_resources_percent],
            ],
          },
          :defaultVmSettings => {
            Node => NodeData[
              :node_type => 'ClusterDasVmSettings',
            ],
            :isolationResponse => LeafData[
              :desc => \
                "isolation response when a virtual machine has no "\
                "HA configuration of its own (ClusterDasVmConfigSpec). ",
              :valid_enum => [:none, :powerOff, :shutdown,],
            ],
            :restartPriority => LeafData[
              :desc => \
                "restart priority when a virtual machine has no HA "\
                "configuration of its own (ClusterDasVmConfigSpec). ",
              :valid_enum => [:disabled, :high, :low, :medium,],
            ],
            :vmToolsMonitoringSettings => {
              Node => NodeData[
                :node_type => 'ClusterVmToolsMonitoringSettings',
              ],
              :failureInterval => LeafData[
                :validate => PuppetX::VMware::Mapper::validate_i_ge(1),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
              :maxFailures => LeafData[
                :validate => PuppetX::VMware::Mapper::validate_i_ge(-1),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
              :maxFailureWindow => LeafData[
                :validate => PuppetX::VMware::Mapper::validate_i_ge(-1),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
              :minUpTime => LeafData[
                :validate => PuppetX::VMware::Mapper::validate_i_ge(1),
                :munge => PuppetX::VMware::Mapper::munge_to_i,
              ],
              :vmMonitoring => LeafData[
                :munge => PuppetX::VMware::Mapper::munge_to_sym,
                :valid_enum => [
                    :vmMonitoringDisabled,
                    :vmMonitoringOnly,
                    :vmAndAppMonitoring,
                ],
              ],
            },
          },
          :hostMonitoring => LeafData[
              :desc => "Is host monitoring enabled? enabled or disabled",
              :valid_enum => [:enabled, :disabled],
          ],
          :vmMonitoring => LeafData[
            :prop_name => :das_config_vm_monitoring,
            :munge => PuppetX::VMware::Mapper::munge_to_sym,
            :valid_enum => [
                :vmMonitoringDisabled,
                :vmMonitoringOnly,
                :vmAndAppMonitoring,
            ],
          ],
        },
      }

      super
    end
  end

end
