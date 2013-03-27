# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# This resource is not ready for testing:
#vc_vm { 'test':
#  path      => '/dc1/192.168.232.240',
#  transport => Transport['vcenter'],
#}
#
vc_vm { $vm1['name']:
   datacenter_name => $dc1['name'],
   power_state     => $vm1['power_state'],
   transport       => Transport['vcenter'],
} 
  
