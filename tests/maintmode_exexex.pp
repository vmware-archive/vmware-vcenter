# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

# test use of meaningless suffix to enable 
# reuse of resource as a command

esx_maintmode { "${esx1['hostname']}:e1}":
  ensure                    => present,
  transport                 => Transport['vcenter'],
} ~>
esx_maintmode { "${esx1['hostname']}:x1}":
  ensure                    => absent,
  transport                 => Transport['vcenter'],
} ~>
esx_maintmode { "${esx1['hostname']}:e2}":
  ensure                    => present,
  transport                 => Transport['vcenter'],
} ~>
esx_maintmode { "${esx1['hostname']}:x2}":
  ensure                    => absent,
  transport                 => Transport['vcenter'],
} ~>
esx_maintmode { "${esx1['hostname']}:e3}":
  ensure                    => present,
  transport                 => Transport['vcenter'],
} ~>
esx_maintmode { "${esx1['hostname']}:x3}":
  ensure                    => absent,
  transport                 => Transport['vcenter'],
}
