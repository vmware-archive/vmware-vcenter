# Copyright (C) 2013 VMware, Inc.
transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_ntpconfig { '192.168.232.240':
  server    => ['ntp.puppetlabs.com','ntp.puppetlabs.lan'],
  transport => Transport['vcenter'],
}
