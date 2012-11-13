transport { 'vcenter':
  username => 'root',
  password => 'vmware',
  server   => '192.168.232.147',
}

notify { 'trigger': }

esx_service { '192.168.232.240:ntpd':
  running   => false,
  policy    => 'on',
  transport => Transport['vcenter'],
  subscribe => Notify['trigger'],
}
