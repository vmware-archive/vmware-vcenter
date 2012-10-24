# Manage vcenter host resource
define vcenter::host (
  $path,
  $username,
  $password,
  $transport,
  $dateTimeConfig = undef,
) {

  $default = {
    'ntpConfig' => {
      'server' => 'ntp.puppetlabs.lan',
    },
  }

  $dtconf = merge($default, $dateTimeConfig)

  vc_host { $name:
    ensure    => present,
    path      => $path,
    username  => $username,
    password  => $password,
    transport => $transport,
  }

  esx_ntpconfig { $name:
    ensure    => present,
    server    => $dtconf['ntpConfig']['server'],
    transport => $transport,
  }

  #esx_service { "${name}:ntp":
  #  ensure    => running,
  #  subscribe => Vc_host_config_datetimeinfo_ntpconfig[$name],
  #}

}
