# Manage vcenter host resource
define vcenter::host (
  $path,
  $username,
  $password,
  $dateTimeConfig = undef,
  # transport is a metaparameter
) {

  $default = {
    'ntpConfig' => {
      'server' => ['ntp.puppetlabs.lan'],
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
    subscribe => Esx_ntpconfig[$name],
  }
}
