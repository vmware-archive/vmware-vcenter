transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
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
