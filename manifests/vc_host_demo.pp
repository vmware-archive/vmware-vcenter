# Copyright (C) 2013 VMware, Inc.
import 'sample_data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_datacenter { $dc1['name']:
  ensure    => present,
  path      => $dc1['path'],
  transport => Transport['vcenter'],
}

Vc_cluster {
  transport => Transport['vcenter'] }

Vc_cluster_evc {
  transport => Transport['vcenter'] }

Vc_cluster_drs {
  transport => Transport['vcenter'] }

Vc_datacenter {
  transport => Transport['vcenter'] }

$dc_name = $dc1['name']
$dc_path = $dc1['path']

# Note: vc::anchor serves as container for cluster configuration:
#
#     vc::anchor { '$cluster_path': }
#
# This anchor marks completion of cluster configuration, If a change in EVC is
# requested, manual setting of EVC is required. The EVC resource should specify
# 'before => vc::anchor[$cluster_path]'.
#
# Resources that require a fully configured cluster (such as hosts to be added
# to the cluster) should specify 'require => vc::anchor[$cluster_path]', not
# 'require Vc_cluster[$cluster_path]'.
#
define vc::anchor {
  anchor { $name: require => Vc_cluster[$name], }
}

# --- cluster tc000: create cluster with default configuration
vc_cluster { "${dc_path}/asmcluster": ensure => present, }

vc_host { $esx1['hostname']:
  ensure    => present,
  path      => "${dc_path}/asmcluster",
  username  => $esx1['username'],
  password  => $esx1['password'],
  transport => Transport['vcenter'],
}

esx_vswitch { 'name':
  require        => Vc_host[$esx1['hostname']],
  name           => "vSwitch2",
  ensure         => present,
  host           => $esx1['hostname'],
  path           => "${dc_path}/asmcluster",
  num_ports      => 120,
  nics           => ["vmnic6", "vmnic7"],
  nicorderpolicy => {
    activenic => ["vmnic6", "vmnic7"],
  },
  mtu            => 5000,
  checkbeacon    => true,
  transport      => Transport['vcenter'],
}

esx_portgroup { 'name':
  require                => Esx_vswitch['name'],
  name                   => "demoportgroup",
  ensure                 => present,
  portgrouptype          => "VMkernel",
  failback               => "true",
  mtu                    => "2014",
  overridefailoverorder  => "Disabled",
  nicorderpolicy         => {
    activenic => ["vmnic1"],
  }
  ,
  checkbeacon            => true,
  vmotion                => "Enabled",
  ipsettings             => "dhcp",
  traffic_shaping_policy => "Enabled",
  averagebandwidth       => 1000,
  peakbandwidth          => 1000,
  burstsize              => 1024,
  vswitch                => vSwitch2,
  host                   => $esx1['hostname'],
  path                   => "${dc_path}/asmcluster",
  vlanid                 => 151,
  transport              => Transport['vcenter'],
}

esx_mem { $esx1['hostname']:
  require                   => Esx_portgroup['name'],
  configure_mem		        => "true",
  install_mem               => "true",
  script_executable_path    => $mem['script_executable_path'],
  setup_script_filepath     => $mem['setup_script_filepath'],
  host_username             => $esx1['username'],
  host_password             => $esx1['password'],
  storage_groupip           => $configure_mem['storage_groupip'],
  iscsi_vmkernal_prefix     => $configure_mem['iscsi_vmkernal_prefix'],
  vnics_ipaddress           => $configure_mem['vnics_ipaddress'],
  iscsi_vswitch             => $configure_mem['iscsi_vswitch'],
  iscsi_netmask             => $configure_mem['iscsi_netmask'],
  vnics                     => $configure_mem['vnics'],
  iscsi_chapuser            => $configure_mem['iscsi_chapuser'],
  iscsi_chapsecret          => $configure_mem['iscsi_chapsecret'],
  disable_hw_iscsi          => $configure_mem['disable_hw_iscsi'],
  transport => Transport['vcenter'],
}

esx_rescanallhba { 'host':
  require   => Esx_mem[$esx1['hostname']],
  host      => "${esx1['hostname']}",
  ensure    => present,
  transport => Transport['vcenter'],
}

esx_datastore { "${esx1['hostname']}:vmfs_datastore":
  require   => Esx_rescanallhba['host'],
  ensure    => present,
  type      => "${esx_ds['type']}",
  target_iqn => "${esx_ds['target_iqn']}",
  path       => "${dc_path}/asmcluster",
  transport => Transport['vcenter'],
}