transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}
vc_datacenter { 'testClusters':
  path      => '/testClusters',
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_cluster { '/testClusters/tc000': transport => Transport['vcenter'], ensure    => absent, }

vc_cluster { '/testClusters/drs001': transport => Transport['vcenter'], ensure    => absent, }
vc_cluster { '/testClusters/drs002': transport => Transport['vcenter'], ensure    => absent, }
vc_cluster { '/testClusters/drs003': transport => Transport['vcenter'], ensure    => absent, }
vc_cluster { '/testClusters/drs004': transport => Transport['vcenter'], ensure    => absent, }

vc_cluster { '/testClusters/evc001': transport => Transport['vcenter'], ensure    => absent, }
vc_cluster { '/testClusters/evc002': transport => Transport['vcenter'], ensure    => absent, }
vc_cluster { '/testClusters/evc003': transport => Transport['vcenter'], ensure    => absent, }
vc_cluster { '/testClusters/evc004': transport => Transport['vcenter'], ensure    => absent, }
