# Note on cluster anchor:
#  anchor { '$cluster_path':
#    require => Vc_cluster['$cluster_path'],
#  }
#
# This anchor marks completion of cluster configuration,
# which may be a multi-step or multi-run process.
#
# If a change in EVC is requested, manual setting of EVC is 
# required. The EVC resource should specify 'before => Anchor[$cluster_path]'.
#
# Steps that require a fully configured cluster (such as hosts to
# be added to the cluster) should specify 'require => Anchor[$cluster_path]', 
# not 'require Vc_cluster[$cluster_path]'.

transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => 'vc0.rbbrown.dev'
}
vc_datacenter { 'testClusters':
  path      => '/testClusters',
  ensure    => present,
  transport => Transport['vcenter'],
}

# --- cluster tc000: create cluster with default configuration
vc_cluster { '/testClusters/tc000':
  transport => Transport['vcenter'],
  ensure    => present,
}
vc_cluster_drs { '/testClusters/tc000':
  transport => Transport['vcenter'],
  require => Vc_cluster['/testClusters/tc000'],
  before => Anchor['/testClusters/tc000'],
  #
  # enabled => false,
}
vc_cluster_evc { '/testClusters/tc000':
  transport => Transport['vcenter'],
  require => [
      Vc_cluster['/testClusters/tc000'],
      Vc_cluster_drs['/testClusters/tc000'],
    ],
  before => Anchor['/testClusters/tc000'],
  #
  # evc_mode_key => 'disabled',
}
anchor { '/testClusters/tc000':
  require => Vc_cluster['/testClusters/tc000'],
  #
  # This anchor marks completion of cluster configuration,
  # which may be a multi-step or multi-run process.
  #
  # If a change in EVC is requested, manual setting of EVC is 
  # required. The EVC resource should specify 'before => Anchor[..]'.
  #
  # Steps that require a fully configured cluster (such as hosts to
  # be added to the cluster) should specify 'require => Anchor[..]', 
  # not 'require Vc_cluster[..]'.
  #
}

# --- cluster drs001: all basic DRS, fully on
vc_cluster { '/testClusters/drs001':
  transport => Transport['vcenter'],
  ensure    => present,
}
vc_cluster_drs { '/testClusters/drs001':
  transport => Transport['vcenter'],
  require => Vc_cluster['/testClusters/drs001'],
  before => Anchor['/testClusters/drs001'],
  #
  enabled => true,
  enable_vm_behavior_overrides => true,
  default_vm_behavior => 'fullyAutomated',
  vmotion_rate => 1,
}
vc_cluster_evc { '/testClusters/drs001':
  transport => Transport['vcenter'],
  require => [
      Vc_cluster['/testClusters/drs001'],
      Vc_cluster_drs['/testClusters/drs001'],
    ],
  before => Anchor['/testClusters/drs001'],
  #
  evc_mode_key => 'disabled',
}
anchor { '/testClusters/drs001':
  require => Vc_cluster['/testClusters/drs001'],
}

# --- cluster evc001: invalid evc mode - check for supported list, including 'disabled'
vc_cluster { '/testClusters/evc001':
  transport => Transport['vcenter'],
  ensure    => present,
}
vc_cluster_drs { '/testClusters/evc001':
  transport => Transport['vcenter'],
  require => Vc_cluster['/testClusters/evc001'],
  before => Anchor['/testClusters/evc001'],
  #
  enabled => true,
}
vc_cluster_evc { '/testClusters/evc001':
  transport => Transport['vcenter'],
  require => [
      Vc_cluster['/testClusters/evc001'],
      Vc_cluster_drs['/testClusters/evc001'],
    ],
  before => Anchor['/testClusters/evc001'],
  #
  evc_mode_key => 'disabledX',
}
anchor { '/testClusters/evc001':
  require => Vc_cluster['/testClusters/evc001'],
}

# --- cluster evc002: evc mode 'disabled' - rerun after enabling EVC Mode, check for failure
vc_cluster { '/testClusters/evc002':
  transport => Transport['vcenter'],
  ensure    => present,
}
vc_cluster_drs { '/testClusters/evc002':
  transport => Transport['vcenter'],
  require => Vc_cluster['/testClusters/evc002'],
  before => Anchor['/testClusters/evc002'],
  #
}
vc_cluster_evc { '/testClusters/evc002':
  transport => Transport['vcenter'],
  require => [
      Vc_cluster['/testClusters/evc002'],
      Vc_cluster_drs['/testClusters/evc002'],
    ],
  before => Anchor['/testClusters/evc002'],
  #
  evc_mode_key => 'disabled',
}
anchor { '/testClusters/evc002':
  require => Vc_cluster['/testClusters/evc002'],
}

# --- cluster evc003: evc mode 'intel-westmere'; rerun after setting EVC to match, check for success
vc_cluster { '/testClusters/evc003':
  transport => Transport['vcenter'],
  ensure    => present,
}
vc_cluster_drs { '/testClusters/evc003':
  transport => Transport['vcenter'],
  require => Vc_cluster['/testClusters/evc003'],
  before => Anchor['/testClusters/evc003'],
  #
}
vc_cluster_evc { '/testClusters/evc003':
  transport => Transport['vcenter'],
  require => [
      Vc_cluster['/testClusters/evc003'],
      Vc_cluster_drs['/testClusters/evc003'],
    ],
  before => Anchor['/testClusters/evc003'],
  #
  evc_mode_key => 'intel-westmere',
}
anchor { '/testClusters/evc003':
  require => Vc_cluster['/testClusters/evc003'],
}
