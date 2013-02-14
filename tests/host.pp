import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vcenter::host { $esx1['hostname']:
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
