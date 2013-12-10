# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => "${vcenter['username']}",
  password => "${vcenter['password']}",
  server   => "${vcenter['server']}",
  options  => $vcenter['options'],
}

vc_datacenter { "${dc1['path']}":
  path      => "${dc1['path']}",
  ensure    => present,
  transport => Transport['vcenter'],
}

vcenter::cluster { "${cluster1['path']}":
  ensure    => present,
  transport => Transport['vcenter'],
  currentEVCModeKey => 'disabled',
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType => 'ClusterFailoverResourcesAdmissionControlPolicy',
        cpuFailoverResourcesPercent => 30,
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

vcenter::cluster { "${cluster2['path']}":
  ensure     => present,
  transport  => Transport['vcenter'],
  currentEVCModeKey => 'disabled',
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType =>  'ClusterFailoverHostAdmissionControlPolicy',
        failoverHosts => [ "${esx4['hostname']}" ],
      },
      defaultVmSettings => {
        isolationResponse => 'shutdown',
        restartPriority   => 'high',
        vmToolsMonitoringSettings => {
          failureInterval   => 30,
          maxFailures       => 3,
          maxFailureWindow => -1,
          minUpTime         => 120,
          vmMonitoring      => 'vmAndAppMonitoring',
        },
      },
      hostMonitoring => enabled,
      vmMonitoring  => 'vmMonitoringOnly',
    },
  },
}

vcenter::cluster { "${cluster3['path']}":
  ensure    => present,
  transport => Transport['vcenter'],
  currentEVCModeKey => 'disabled',
  clusterConfigSpecEx => {
    dasConfig => {
      enabled => true,
      admissionControlEnabled => true,
      admissionControlPolicy => {
        vsphereType =>  'ClusterFailoverLevelAdmissionControlPolicy',
        failoverLevel => 2,
      },
      hostMonitoring => enabled,
      vmMonitoring  => 'vmMonitoringDisabled',
    },
  },
}
