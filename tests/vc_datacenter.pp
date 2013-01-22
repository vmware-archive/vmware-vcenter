transport { 'vcenter':
  username => $vcsa_user,
  password => $vcsa_pass,
  server   => $vcsa_ip,
}

vc_datacenter { 'dc1':
  path      => '/dc1',
  ensure    => present,
  transport => Transport['vcenter'],
}

vc_datacenter { 'dc2':
  path      => '/dc2',
  ensure    => present,
  transport => Transport['vcenter'],
}
