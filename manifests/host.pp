# Copyright (C) 2013 VMware, Inc.
# Manage vcenter host resource
define vcenter::host (
  $path,
  $username,
  $password,
  $dateTimeConfig = {},
  $shells         = {},
  $servicesConfig = {},
  # transport is a metaparameter
) {

  $default_dt = {
    ntpConfig => {
      running => true,
      policy => 'automatic',
      server => [ '0.pool.ntp.org', '1.pool.ntp.org', ],
    },
    timeZone => {
      key => 'UTC',
    },
  }
  $config_dt = merge($default_dt, $dateTimeConfig)

  $default_shell = {
    esxi_shell => {
      running => false,
      policy => 'off',
    },
    ssh => {
      running => false,
      policy => 'off',
    },
    esxi_shell_time_out => 0,
    esxi_shell_interactive_time_out => 0,
    suppress_shell_warning => 0,
  }
  $config_shells = merge($default_shell, $shells)

  $default_svcs = {
    dcui => {
      running => true,
      policy => 'on',
    },
  }
  $config_svcs = merge($default_svcs, $servicesConfig)

  vc_host { $name:
    ensure    => present,
    path      => $path,
    username  => $username,
    password  => $password,
    transport => $transport,
  }

  # ntp
  esx_ntpconfig { $name:
    server    => $config_dt['ntpConfig']['server'],
    transport => $transport,
  }

  esx_service { "${name}:ntpd":
    policy    => $config_dt['ntpConfig']['policy'],
    running   => $config_dt['ntpConfig']['running'],
    subscribe => Esx_ntpconfig[$name],
    transport => $transport,
  }

  # shells
  esx_shells { $name:
    # to disable cluster/host status warnings:
    #   http://kb.vmware.com/kb/2034841 ESXi 5.1 and related articles
    #   esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i (0|1)
    #   vSphere API: advanced settings UserVars.SuppressShellWarning = (0|1) [type long]
    suppress_shell_warning => $config_shells['suppress_shell_warning'],
    # timeout means 'x minutes after enablement, disable new logins'
    #   vSphere API: advanced settings UserVars.ESXiShellTimeOut = [type long] (0 disables)
    #   http://kb.vmware.com/kb/2004746 ; timeout isn't 'log out user after x minutes inactivity'
    esxi_shell_time_out  => $config_shells['esxi_shell_time_out'],
    # interactiveTimeOut means 'log out user after x minutes inactivity'
    #   vSphere API: advanced settings UserVars.ESXiShellInteractiveTimeOut = [type long] (0 disables)
    esxi_shell_interactive_time_out  => $config_shells['esxi_shell_interactive_time_out'],
    transport => $transport,
  }

  esx_service { "${name}:TSM":
    policy    => $config_shells['esxi_shell']['policy'],
    running   => $config_shells['esxi_shell']['running'],
    subscribe => Esx_shells[$name],
    transport => $transport,
  }
  esx_service { "${name}:TSM-SSH":
    policy    => $config_shells['ssh']['policy'],
    running   => $config_shells['ssh']['running'],
    subscribe => Esx_shells[$name],
    transport => $transport,
  }

  # simple services
  # - fully managed by HostServiceSystem
  # - behaviors are boot-time enablement and running/stopped
  # - vSphere API provides no additional configuration
  esx_service { "${name}:DCUI":
    policy  => $config_svcs['dcui']['policy'],
    running => $config_svcs['dcui']['running'],
    transport => $transport,
  }
}
