import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
vc_vsan_health_performance { 'vsan_config':
  ensure => present,
  datacenter => $dc1['name'],
  cluster => $cluster1['name'],
  transport => Transport['vcenter'],
}

