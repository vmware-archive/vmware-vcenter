# Manage vcenter host resource
define vcenter::host (
  $path,
  $username,
  $password,
  $dateTimeConfig = {},
  # transport is a metaparameter
) {

  $default = {
    ntpConfig => {
      running => true,
      policy => 'automatic',
      server => [ '0.pool.ntp.org', '1.pool.ntp.org', ],
    },
    timeZone => {
      key => 'UTC',
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
    server    => $dtconf['ntpConfig']['server'],
    transport => $transport,
  }

  # We do not need to manage the enure state.
  esx_service { "${name}:ntpd":
    policy  => $dtconf['ntpConfig']['policy'],
    running => $dtconf['ntpConfig']['running'],
    subscribe => Esx_ntpconfig[$name],
  }
}
