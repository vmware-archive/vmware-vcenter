transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => 'vc0.rbbrown.dev'
}

vcenter::cluster { '/dc1/clu1':
  ensure    => present,
  transport => Transport['vcenter'],
  currentEVCModeKey => 'disabled',
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType => 'ClusterFailoverResourcesAdmissionControlPolicy',
        cpuFailoverResourcesPercent => 25,
        memoryFailoverResourcesPercent => 30,
      },
      defaultVmSettings => {
        isolationResponse => 'powerOff',
        restartPriority   => 'high',
        vmToolsMonitoringSettings => {
          failureInterval   => 40,
          maxFailures       => 4,
          maxFailureWindow => -1,
          minUpTime         => 300,
          vmMonitoring      => 'vmMonitoringOnly',
        },
      },
      hostMonitoring => enabled,
      vmMonitoring  => 'vmAndAppMonitoring',
    },
  },
}

vcenter::cluster { '/dc1/clu2':
  ensure     => present,
  transport  => Transport['vcenter'],
  currentEVCModeKey => 'disabled',
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType =>  'ClusterFailoverHostAdmissionControlPolicy',
        # failoverHosts => ['host-51', 'host-53'],
      },
      defaultVmSettings => {
        isolationResponse => 'shutdown',
        restartPriority   => 'high',
        vmToolsMonitoringSettings => {
          failureInterval   => 30,
          maxFailures       => 3,
          maxFailureWindow => -1,
          minUpTime         => 120,
          vmMonitoring      => 'vmMonitoringOnly',
        },
      },
      hostMonitoring => enabled,
      vmMonitoring  => 'vmMonitoringOnly',
    },
  },
}

vcenter::cluster { '/dc1/clu3':
  ensure    => present,
  transport => Transport['vcenter'],
  currentEVCModeKey => 'disabled',
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType =>  'ClusterFailoverLevelAdmissionControlPolicy',
        failoverLevel => 1,
      },
      hostMonitoring => disabled,
      vmMonitoring  => 'vmMonitoringDisabled',
    },
  },
}
