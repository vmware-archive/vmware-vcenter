# Copyright (C) 2013 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vc_vpxsettings) do
  @doc = "Manage vCenter vpxsettings ( event.maxAge, mail.smtp.server, etc )"

  newparam(:name, :namevar => true) do
    desc "The vm name"
  end

  # could not create individual properties due to dots existing in the prop names
  newproperty(:vpx_settings,:parent => Puppet::Property::VMware_Hash) do
    desc "hash of vpxsetting for a given vcenter, this must match the api parameters
          exactly ( including case ) inside of setting[], that is shown from the below:
         
           1. browse to https://<vcenter>/mob/?moid=ServiceInstance&method=retrieveContent
           2. click on Invoke Method,
           3. select VpxSettings

          example: setting['event.maxAge'] and setting['event.maxAgeEnabled'] would be

                 vpx_settings => { 'event.maxAge' => 14, 'event.maxAgeEnabled' => true, }

         "
    validate do |value|
      value.each do |k,v|
        if k =~ /enabled$/i
          fail("value: #{v} must match true/false") if v.to_s !~ /^(false|true)$/
        else
          fail("value: #{v} must match valid word character") if v.to_s !~ /\w/
        end
      end
    end
  end

end
