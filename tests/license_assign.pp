# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_license_assignment { "${esx1['hostname']}":
	license_key => $license1,
  transport => Transport['vcenter'],
}
