import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
vc_vsan_network { 'vsan_config':
  ensure => present,
  datacenter => $dc1['name'],
  cluster => $cluster1['name'],
  vsan_port_group_name => 'vsan',
  transport => Transport['vcenter'],
}

