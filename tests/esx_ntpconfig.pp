transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

esx_ntpconfig { '192.168.232.240':
  #  ensure    => present,
  server    => ['ntp.puppetlabs.com'],
  transport => Transport['vcenter'],
}
