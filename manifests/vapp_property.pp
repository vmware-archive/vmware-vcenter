class vcenter::vapp_property (
  $vc_username,
  $vc_password,
  $vc_hostname,
  $dc,
  $vmname,
  $property,
  $transport_options   = {},
  $ensure              = undef,
  $category            = undef,
  $class_id            = undef,
  $default_value       = undef,
  $description         = undef,
  $property_id         = undef,
  $instance_id         = undef,
  $property_type       = undef,
  $user_configurable   = undef,
  $value               = undef,
) {

  transport { "vcenter":
    username => "$vc_username",
    password => "$vc_password",
    server   => $vc_hostname,
    options  => $transport_options,
  }

  vm_vapp_property { "$dc:$vmname:$property":
    ensure            => $ensure,
    category          => $category,
    class_id          => $class_id,
    default_value     => $default_value,
    description       => $description,
    id                => $property_id,
    instance_id       => $instance_id,
    type              => $property_type,
    user_configurable => $user_configurable,
    value             => $value,
    transport         => Transport["vcenter"],
  }
}
