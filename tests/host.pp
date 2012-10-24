transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

vcenter::host { '192.168.232.240':
  path      => '/dc1',
  username  => 'root',
  password  => 'password',
  dateTimeConfig => {
    'ntpConfig' => {
      'server' => 'ntp.puppetlabs.lan',
    },
    'timeZone' => {
      'key' => 'UTC',
    },
  },
  transport => Transport['vcenter'],
}
