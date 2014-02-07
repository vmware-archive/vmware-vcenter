# Copyright (C) 2014 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => {
    "insecure" => true,
    "rev" => "5.1",
  },
}

vc_extension { "com.vmware.vcHms":
  ensure                    => absent,
  transport                 => Transport['vcenter'],
}
