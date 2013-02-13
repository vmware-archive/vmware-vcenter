import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Vc_datacenter {
  transport => Transport['vcenter'],
}

vc_datacenter { 'dc1':
  ensure    => present,
  path      => '/dc1',
}

vc_datacenter { 'dc2':
  ensure    => absent,
  path      => '/dc2',
}
