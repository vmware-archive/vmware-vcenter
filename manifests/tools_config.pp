class vcenter::tools_config (
  $vc_username,
  $vc_password,
  $vc_hostname,
  $dc,
  $vmname,
  $transport_options     = {},
  $after_power_on        = undef,
  $after_resume          = undef,
  $before_guest_reboot   = undef,
  $before_guest_shutdown = undef,
  $before_guest_standby  = undef,
  $sync_time_with_host   = undef,
  $tools_upgrade_policy  = undef,
) {

  transport { "vcenter":
    username => "$vc_username",
    password => "$vc_password",
    server   => $vc_hostname,
    options  => $transport_options,
  }

  vm_tools_config { "$dc:$vmname":
    after_power_on        => $after_power_on,
    after_resume          => $after_resume,
    before_guest_reboot   => $before_guest_reboot,
    before_guest_shutdown => $before_guest_shutdown,
    before_guest_standby  => $before_guest_standby,
    sync_time_with_host   => $sync_time_with_host,
    tools_upgrade_policy  => $tools_upgrade_policy,
    transport             => Transport["vcenter"],
  }
}
