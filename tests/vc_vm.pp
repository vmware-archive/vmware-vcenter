import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
vc_vm { 'test':
  path      => '/dc1/192.168.232.240',
  transport => Transport['vcenter'],
}
