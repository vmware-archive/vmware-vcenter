# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Vc_cluster { transport => Transport['vcenter'] }
Vc_cluster_evc { transport => Transport['vcenter'] }
Vc_cluster_drs { transport => Transport['vcenter'] }
Vc_datacenter { transport => Transport['vcenter'] }

$dc_name = $dc1['name']
$dc_path = $dc1['path']

# Note: vc::anchor serves as container for cluster configuration:
#
#     vc::anchor { '$cluster_path': }
#
# This anchor marks completion of cluster configuration, If a change in EVC is
# requested, manual setting of EVC is required. The EVC resource should specify
# 'before => vc::nchor[$cluster_path]'.
#
# Resources that require a fully configured cluster (such as hosts to be added
# to the cluster) should specify 'require => vc::anchor[$cluster_path]', not
# 'require Vc_cluster[$cluster_path]'.
#
define vc::anchor {
  anchor { $name:
    require => Vc_cluster[$name],
  }
}

vc_datacenter { $dc_name:
  ensure => present,
  path   => $dc_path,
}

# --- cluster tc000: create cluster with default configuration
vc_cluster { "${dc_path}/tc000":
  ensure => present,
}

vc_cluster_drs { "${dc_path}/tc000":
  require => Vc_cluster["${dc_path}/tc000"],
  before  => Anchor["${dc_path}/tc000"],
}

vc_cluster_evc { "${dc_path}/tc000":
  require => [
    Vc_cluster["${dc_path}/tc000"],
    Vc_cluster_drs["${dc_path}/tc000"],
  ],
  before  => Anchor["${dc_path}/tc000"],
}

vc::anchor { "${dc_path}/tc000": }

# --- cluster drs001: all basic DRS, fully on
vc_cluster { "${dc_path}/drs001":
  ensure    => present,
}

vc_cluster_drs { "${dc_path}/drs001":
  enabled                      => true,
  enable_vm_behavior_overrides => true,
  default_vm_behavior          => 'fullyAutomated',
  vmotion_rate                 => 1,
  require                      => Vc_cluster["${dc_path}/drs001"],
  before                       => Anchor["${dc_path}/drs001"],
}

vc_cluster_evc { "${dc_path}/drs001":
  evc_mode_key => 'disabled',
  require      => [
    Vc_cluster["${dc_path}/drs001"],
    Vc_cluster_drs["${dc_path}/drs001"],
  ],
  before       => Anchor["${dc_path}/drs001"],
}

vc::anchor { "${dc_path}/drs001": }

# --- cluster evc001: invalid evc mode
# check for supported list, including "disabled"
# Puppet should propagate vSphere API error:
# Warning: Unsupported EVC Mode Key: 'disabledX'
vc_cluster { "${dc_path}/evc001":
  ensure => present,
} ->

vc_cluster_drs { "${dc_path}/evc001":
  enabled => true,
  require => Vc_cluster["${dc_path}/evc001"],
  before  => Anchor["${dc_path}/evc001"],
}

vc_cluster_evc { "${dc_path}/evc001":
  evc_mode_key => 'disabledX',
  require      => [
    Vc_cluster["${dc_path}/evc001"],
    Vc_cluster_drs["${dc_path}/evc001"],
  ],
  before       => Anchor["${dc_path}/evc001"],
}

vc::anchor { "${dc_path}/evc001": }

# --- cluster evc002: evc mode "disabled"
# rerun after enabling EVC Mode, check for failure
vc_cluster { "${dc_path}/evc002":
  ensure => present,
}

vc_cluster_drs { "${dc_path}/evc002":
  require => Vc_cluster["${dc_path}/evc002"],
  before  => Anchor["${dc_path}/evc002"],
}

vc_cluster_evc { "${dc_path}/evc002":
  evc_mode_key => 'disabled',
  require      => [
    Vc_cluster["${dc_path}/evc002"],
    Vc_cluster_drs["${dc_path}/evc002"],
  ],
  before       => Anchor["${dc_path}/evc002"],
}

vc::anchor { "${dc_path}/evc002": }

# --- cluster evc003: evc mode "intel-westmere"
# rerun after manually setting EVC to match, check for success
# Puppet should provide the following warning:
# Error: You must use vCenter client to set EVCMode. This software supports
# verifying a cluster's EVC Mode Key but cannot set it.
vc_cluster { "${dc_path}/evc003":
  ensure => present,
}

vc_cluster_drs { "${dc_path}/evc003":
  require => Vc_cluster["${dc_path}/evc003"],
  before  => Anchor["${dc_path}/evc003"],
}

vc_cluster_evc { "${dc_path}/evc003":
  evc_mode_key => 'intel-westmere',
  require      => [
    Vc_cluster["${dc_path}/evc003"],
    Vc_cluster_drs["${dc_path}/evc003"],
  ],
  before       => Anchor["${dc_path}/evc003"],
}

vc::anchor { "${dc_path}/evc003": }
