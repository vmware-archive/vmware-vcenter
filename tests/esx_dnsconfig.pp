# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_dnsconfig { $esx1['hostname']:
  address       => ['8.8.8.8', '8.8.4.4'],
  host_name     => 'lab-esx01',
  domain_name   => 'lab.tld',
  search_domain => 'lab.tld',
  dhcp          => false,
  transport     => Transport['vcenter'],
}
