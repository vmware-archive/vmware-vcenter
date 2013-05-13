# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

vcenter::iscsi_send_target { "${esx2['hostname']}:vmhba33":
  ensure                    => present,
  targets => {
    #digest_properties_header_digest_inherited
    #digest_properties_header_digest_type
    #digest_properties_data_digest_inherited
    #digest_properties_data_digest_type
    #authentication_properties_mutual_chap_inherited
    #authentication_properties_chap_authentication_type
    #authentication_properties_mutual_chap_name
    #authentication_properties_chap_inherited
    #authentication_properties_mutual_chap_secret
    #authentication_properties_mutual_chap_authentication_type
    #authentication_properties_chap_auth_enabled
    address => ${iscsi_target_ip},
    port => 3260,
    advanced_options => [
      {key => 'DelayedAck', value => true, isInherited => false}
    ],
    #parent
  },
  transport                 => Transport['vcenter'],
}
