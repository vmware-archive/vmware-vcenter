# Manage vcenter compute cluster resource
define vcenter::cluster (
  # title is a metaparameter
  $ensure,
  $modify = true,
  $currentEVCModeKey = 'disabled',
  $clusterConfigSpecEx = {},
  # transport is a metaparameter
) {

  $path = $title

  $spec = $clusterConfigSpecEx

  vc_cluster { $path:
    ensure    => $ensure,
    transport => $transport,
    before => Anchor[$path],
  }

  vc_cluster_ha { $path:
    admission_control_enabled         => nested_value($spec, ['dasConfig', 'admissionControlEnabled']),
    admission_control_policy_type     => nested_value($spec, ['dasConfig', 'admissionControlPolicy', 'vsphereType']),
    cpu_failover_resources_percent    => nested_value($spec, ['dasConfig', 'admissionControlPolicy', 'cpuFailoverResourcesPercent']),
    memory_failover_resources_percent => nested_value($spec, ['dasConfig', 'admissionControlPolicy', 'memoryFailoverResourcesPercent']),
    failover_hosts                    => nested_value($spec, ['dasConfig', 'admissionControlPolicy', 'failoverHosts']),
    failover_level                    => nested_value($spec, ['dasConfig', 'admissionControlPolicy', 'failoverLevel']),
    isolation_response                => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'isolationResponse']),
    restart_priority                  => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'restartPriority']),
    failure_interval                  => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'failureInterval']),
    max_failures                      => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'maxFailures']),
    max_failure_window                => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'maxFailureWindow']),
    min_up_time                       => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'minUpTime']),
    vm_monitoring                     => nested_value($spec, ['dasConfig', 'defaultVmSettings', 'vmToolsMonitoringSettings', 'vmMonitoring']),
    das_config_enabled                => nested_value($spec, ['dasConfig', 'enabled']),
    host_monitoring                   => nested_value($spec, ['dasConfig', 'hostMonitoring']),
    das_config_vm_monitoring          => nested_value($spec, ['dasConfig', 'vmMonitoring']),
    #
    transport => $transport,
    require => Vc_cluster[$path],
    before => Anchor[$path],
  }

  vc_cluster_evc { $path:
    evc_mode_key => $currentEVCModeKey,
    #
    transport => $transport,
    require => Vc_cluster_ha[$path],
    before => Anchor[$path],
  }

  anchor { $path:
  }
}
