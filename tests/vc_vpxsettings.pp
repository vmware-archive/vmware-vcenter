# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vc_vpxsettings { $vcenter['server']:
  vpx_settings => $vpx_settings,
  transport => Transport['vcenter'],
}
