# Copyright (C) 2013 VMware, Inc.
# Manage iSCSI Send Targets
define vcenter::iscsi_send_target (
  $ensure,
  $targets = {},
    # transport is a metaparameter
) {

  $path = $name
  $spec = $targets
  esx_iscsi_targets { $path:
    transport                                           => $transport,
    ensure                                              => $ensure,
    digest_properties_header_digest_inherited           => nested_value($spec, ['digestProperties', 'headerDigestInherited']),
    digest_properties_header_digest_type                => nested_value($spec, ['digestProperties', 'headerDigestType']),
    digest_properties_data_digest_inherited             => nested_value($spec, ['digestProperties', 'dataDigestInherited']),
    digest_properties_data_digest_type                  => nested_value($spec, ['digestProperties', 'dataDigestType']),
    authentication_properties_mutual_chap_inherited     => nested_value($spec, ['authenticationProperties', 'mutualChapInherited']),
    authentication_properties_chap_authentication_type  => nested_value($spec, ['authenticationProperties', 'chapAuthenticationType']),
    authentication_properties_mutual_chap_name          => nested_value($spec, ['authenticationProperties', 'mutualChapName']),
    authentication_properties_chap_inherited            => nested_value($spec, ['authenticationProperties', 'chapInherited']),
    authentication_properties_mutual_chap_secret        => nested_value($spec, ['authenticationProperties', 'mutualChapSecret']),
    authentication_properties_chap_name                 => nested_value($spec, ['authenticationProperties', 'chapName']),
    authentication_properties_chap_secret               => nested_value($spec, ['authenticationProperties', 'chapSecret']),
    authentication_properties_mutual_chap_authentication_type       => nested_value($spec, ['authenticationProperties', 'mutualChapAuthenticationType']),
    authentication_properties_chap_auth_enabled     => nested_value($spec, ['authenticationProperties', 'chapAuthEnabled']),
    address => nested_value($spec, ['address']),
    port    => nested_value($spec, ['port']),
    advanced_options        => nested_value($spec, ['advancedOptions']),
    parent  => nested_value($spec, ['parent']),
  }
}
