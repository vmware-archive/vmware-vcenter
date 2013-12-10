# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

Vc_cluster { transport => Transport['vcenter'] }
Vc_datacenter { transport => Transport['vcenter'] }

$dc_name = $dc1['name']
$dc_path = $dc1['path']

vc_cluster {
  [ "${dc_path}/tc000",
    "${dc_path}/drs001",
    "${dc_path}/drs002",
    "${dc_path}/drs003",
    "${dc_path}/drs004",
    "${dc_path}/evc001",
    "${dc_path}/evc002",
    "${dc_path}/evc003",
    "${dc_path}/evc004",
  ]:
    ensure => absent,
} ->

vc_datacenter { $dc_name:
  ensure => absent,
  path   => $dc_path,
}
