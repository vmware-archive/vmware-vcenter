# Copyright (C) 2013 VMware, Inc.
import 'data.pp'

transport { 'vcenter':
  username => $vcenter['username'],
  password => $vcenter['password'],
  server   => $vcenter['server'],
  options  => $vcenter['options'],
}

esx_advanced_options { $esx1['hostname']:
  options => { 
  "Vpx.Vpxa.config.log.level" => "verbose",                          # ChoiceOption  default "verbose"
  "Config.HostAgent.log.level" => "verbose",                         # ChoiceOption  default "verbose"
  "Annotations.WelcomeMessage" => "",                                # StringOption  default ""
  "BufferCache.SoftMaxDirty" => 15,                                  # LongOption    default 15
  "CBRC.Enable" => false,                                            # BoolOption    default false
  "Config.GlobalSettings.guest.commands.sharedPolicyRefCount" => 0   # IntOption     default 0
  },
  transport      => Transport['vcenter'],
}
