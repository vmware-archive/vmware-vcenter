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

vc_host { '192.168.232.240':
  ensure    => present,
  path      => '/dc1',
  username  => 'root',
  password  => 'password',
  transport => Transport['vcenter'],
}
