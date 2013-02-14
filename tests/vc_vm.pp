# Copyright (C) 2013 VMware, Inc.
transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

vc_vm { 'test2':
  path      => '/dc1/192.168.232.240',
  transport => Transport['vcenter'],
}
