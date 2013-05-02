# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_iscsi_hba_name { "${esx1['hostname']}:vmhba33":
  iscsi_name => "iqn.1998-01.com.vmware.${esx1['hostname']}",
  transport  => Transport['vcenter'],
}

