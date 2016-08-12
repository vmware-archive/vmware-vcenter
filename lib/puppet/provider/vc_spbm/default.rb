provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
require File.join(provider_path, 'spbmapiutils')

Puppet::Type.type(:vc_spbm).provide(:vc_spbm, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manage storage poicy based management for virtual machines."

  def create
    Puppet.debug("Inside create block")
    pm = pbm_manager

    rules = create_rules
    resType = {:resourceType => "STORAGE"}
    constraints = _convertStrRulesToApiStructs(rules)

    pm.PbmCreate(
      :createSpec => {
        :name => resource[:name],
        :description => resource[:description],
        :resourceType => resType,
        :constraints => PBM::PbmCapabilitySubProfileConstraints(
          :subProfiles => [
            PBM::PbmCapabilitySubProfile(
              :name => "Object",
              :capability => constraints
            )
          ]
        )
      }
    )
    true
  end

  def create_rules
    rules = []
    rules << "VSAN.%s=%s" % ["stripeWidth", resource[:stripe_width]] if resource[:stripe_width]
    rules << "VSAN.%s=%s" % ["forceProvisioning", resource[:force_provisioning]] if resource[:force_provisioning]
    rules << "VSAN.%s=%s" % ["proportionalCapacity", resource[:proportional_capacity]] if resource[:proportional_capacity]
    rules << "VSAN.%s=%s" % ["cacheReservation", resource[:cache_reservation]] if resource[:cache_reservation]
    rules << "VSAN.%s=%s" % ["replicaPreference", failure_tolerance_value[resource[:failure_tolerance_method]]] if resource[:failure_tolerance_method]
    rules << "VSAN.%s=%s" % ["hostFailuresToTolerate", resource[:host_failures_to_tolerate]] if resource[:host_failures_to_tolerate]
    rules
  end

  def destroy
    true
  end

  def exists?
    exiting_profiles.find { |x| x.name == resource[:name]}
  end

  def exiting_profiles
    profiles = []
    profileIds = pbm_manager.PbmQueryProfile(
      :resourceType => {:resourceType => "STORAGE"},
      :profileCategory => "REQUIREMENT"
    )

    if profileIds.length > 0
      profiles = pbm_manager.PbmRetrieveContent(:profileIds => profileIds)
    end

    profiles
  end

  def failure_tolerance_value
    {
      'failure_tolerance_raid1' => "RAID-1 (Mirroring) - Performance",
      'failure_tolerance_raid5' => "RAID-5/6 (Erasure Coding) - Capacity"
    }
  end

  def failure_tolerance_method
    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    return [] unless constraints.respond_to?('subProfiles')

    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            return failure_tolerance_value.keys.find { |x|  failure_tolerance_value[x] == property_instance.value }  if property_instance.id == "replicaPreference"
          end
        end
      end
    end
  end

  def failure_tolerance_method=(value)
    return true if value.empty?
    Puppet.debug("Updating value #{value} of replica_preference to #{resource[:failure_tolerance_method]}")
    found = false

    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    rules = []
    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            if property_instance.id == "replicaPreference" && value != 'none'
              property_instance.value = failure_tolerance_value[resource[:failure_tolerance_method]]
              found = true
              rules << "VSAN.%s=%s" % [property_instance.id, failure_tolerance_value[resource[:failure_tolerance_method]]]
            else
              rules << "VSAN.%s=%s" % [property_instance.id, property_instance.value] unless property_instance.id == "replicaPreference"
            end
          end
        end
      end
    end

    if !found && value != 'none'
      rules << "VSAN.%s=%s" % ["replicaPreference", failure_tolerance_value[resource[:failure_tolerance_method]]]
    end
    profile_modify(rules)
    return true
  end


  def host_failures_to_tolerate
    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    return [] unless constraints.respond_to?('subProfiles')

    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            return property_instance.value.to_s if property_instance.id == "hostFailuresToTolerate"
          end
        end
      end
    end
  end

  def host_failures_to_tolerate=(value)
    return true if value.empty?
    Puppet.debug("Updating value #{value} of hostFailuresToTolerate to #{resource[:host_failures_to_tolerate]}")
    found = false

    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    rules = []
    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            if property_instance.id == "hostFailuresToTolerate"
              property_instance.value = resource[:host_failures_to_tolerate]
              found = true
              rules << "VSAN.%s=%s" % [property_instance.id, resource[:host_failures_to_tolerate]]
            else
              rules << "VSAN.%s=%s" % [property_instance.id, property_instance.value]
            end
          end
        end
      end
    end

    rules << "VSAN.%s=%s" % ["hostFailuresToTolerate", resource[:host_failures_to_tolerate]] unless found
    profile_modify(rules)
    return true
  end

  def stripe_width
    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    return [] unless constraints.respond_to?('subProfiles')

    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            return property_instance.value if property_instance.id == "stripeWidth"
          end
        end
      end
    end
  end

  def stripe_width=(value)
    return true if value.empty?
    Puppet.debug("Updating value #{value} of stripeWidth to #{resource[:stripe_width]}")
    found = false

    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    rules = []
    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            if property_instance.id == "stripeWidth"
              property_instance.value = resource[:stripe_width]
              found = true
              rules << "VSAN.%s=%s" % [property_instance.id, resource[:stripe_width]]
            else
              rules << "VSAN.%s=%s" % [property_instance.id, property_instance.value]
            end
          end
        end
      end
    end

    rules << "VSAN.%s=%s" % ["stripeWidth", resource[:stripe_width]] unless found
    profile_modify(rules)
    return true
  end

  def force_provisioning
    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    return [] unless constraints.respond_to?('subProfiles')

    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            return property_instance.value if property_instance.id == "forceProvisioning"
          end
        end
      end
    end
  end

  def force_provisioning=(value)
    return true if value.empty?
    Puppet.debug("Updating value #{value} of forceProvisioning to #{resource[:force_provisioning]}")
    found = false

    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    rules = []
    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            if property_instance.id == "forceProvisioning"
              property_instance.value = resource[:force_provisioning]
              found = true
              rules << "VSAN.%s=%s" % [property_instance.id, resource[:force_provisioning]]
            else
              rules << "VSAN.%s=%s" % [property_instance.id, property_instance.value]
            end
          end
        end
      end
    end

    rules << "VSAN.%s=%s" % ["forceProvisioning", resource[:force_provisioning]] unless found
    profile_modify(rules)
    return true
  end

  def proportional_capacity
    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    return [] unless constraints.respond_to?('subProfiles')

    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            return property_instance.value if property_instance.id == "proportionalCapacity"
          end
        end
      end
    end
  end

  def proportional_capacity=(value)
    return true if value.empty?
    Puppet.debug("Updating value #{value} of proportionalCapacity to #{resource[:proportional_capacity]}")
    found = false

    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    rules = []
    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            if property_instance.id == "proportionalCapacity"
              property_instance.value = resource[:proportional_capacity]
              found = true
              rules << "VSAN.%s=%s" % [property_instance.id, resource[:proportional_capacity]]
            else
              rules << "VSAN.%s=%s" % [property_instance.id, property_instance.value]
            end
          end
        end
      end
    end

    rules << "VSAN.%s=%s" % ["proportionalCapacity", resource[:proportional_capacity]] unless found
    profile_modify(rules)
    return true
  end

  def cache_reservation
    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    return [] unless constraints.respond_to?('subProfiles')

    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            return property_instance.value if property_instance.id == "cacheReservation"
          end
        end
      end
    end
  end

  def cache_reservation=(value)
    return true if value.empty?
    Puppet.debug("Updating value #{value} of cacheReservation to #{resource[:cache_reservation]}")
    found = false

    profile = exiting_profiles.find { |x| x.name == resource[:name]}
    constraints = profile.constraints
    rules = []
    constraints.subProfiles.each do |sub_profile|
      sub_profile.capability.each do |cap|
        cap.constraint.each do |constraint|
          constraint.propertyInstance.each do |property_instance|
            if property_instance.id == "cacheReservation"
              property_instance.value = resource[:cache_reservation]
              found = true
              rules << "VSAN.%s=%s" % [property_instance.id, resource[:cache_reservation]]
            else
              rules << "VSAN.%s=%s" % [property_instance.id, property_instance.value]
            end
          end
        end
      end
    end

    rules << "VSAN.%s=%s" % ["cacheReservation", resource[:cache_reservation]] unless found
    profile_modify(rules)
    return true
  end

  def profile_modify(rules)
      resType = {:resourceType => "STORAGE"}
      constraints = _convertStrRulesToApiStructs(rules)

      pbm_manager.PbmUpdate(
          :profileId => profile.profileId,
          :updateSpec => {
              :description => ( resource[:description] || profile.description),
              :constraints => PBM::PbmCapabilitySubProfileConstraints(
                  :subProfiles => [
                      PBM::PbmCapabilitySubProfile(
                          :name => "Object",
                          :capability => constraints
                      )
                  ]
              )
          }
      )
  end

  def _convertStrRulesToApiStructs(rules)
    resType = {:resourceType => "STORAGE"}

    pm = pbm_manager
    # Need to support other vendors too
    cm = pm.PbmFetchCapabilityMetadata(
        :resourceType => resType,
        :vendorUuid => "com.vmware.storage.vsan"
    )
    capabilities = cm.map{|x| x.capabilityMetadata}.flatten

    constraints = rules.map do |rule_str|
      name, values_str = rule_str.split("=", 2)
      if !values_str
        raise("Rule is malformed: #{rule_str}, should be <provider>.<capability>=<value>")
      end
      ns, id = name.split('.', 2)
      if !id
        raise("Rule is malformed: #{rule_str}, should be <provider>.<capability>=<value>")
      end
      capability = capabilities.find{|x| x.id.id == id}
      if !capability
        raise("Capability #{name} unknown")
      end
      type = capability.propertyMetadata[0].type
      values = values_str.split(',')
      if type.typeName == "XSD_INT"
        values = values.map{|x| RbVmomi::BasicTypes::Int.new(x.to_i)}
      end
      if type.typeName == "XSD_BOOLEAN"
        values = values.map{|x| (x =~ /(true|True|1|yes|Yes)/) != nil}
      end
      if type.is_a?(PBM::PbmCapabilityGenericTypeInfo) && type.genericTypeName == "VMW_RANGE"
        if values.length != 2
          raise("#{name} is a range, need to specify 2 values")
        end
        value = PBM::PbmCapabilityTypesRange(:min => values[0], :max => values[1])
      elsif values.length == 1
        value = values.first
      else
        raise("Value malformed: #{value_str}")
      end

      {
          :id => {
              :namespace => ns,
              :id => id
          },
          :constraint => [{
                              :propertyInstance => [{
                                                        :id => id,
                                                        :value => value
                                                    }]
                          }]
      }
    end
    constraints
  end




  def create_constraint
    resType = {:resourceType => "STORAGE"}
    rules = ["vsan.replicaPreference=1","vsan.hostFailuresToTolerate=2"]

    # Need to support other vendors too
    cm = pbm_manager.PbmFetchCapabilityMetadata(
        :resourceType => resType,
        :vendorUuid => "com.vmware.storage.vsan"
    )
    capabilities = cm.map{|x| x.capabilityMetadata}.flatten
    constraints = rules.map do |rule_str|
      name, values_str = rule_str.split("=", 2)
      if !values_str
        raise "Rule is malformed: #{rule_str}, should be <provider>.<capability>=<value>"
      end
      ns, id = name.split('.', 2)
      if !id
        raise "Rule is malformed: #{rule_str}, should be <provider>.<capability>=<value>"
      end
      capability = capabilities.find{|x| x.id.id == id}
      if !capability
        raise "Capability #{name} unknown"
      end
      type = capability.propertyMetadata[0].type
      values = values_str.split(',')
      if type.typeName == "XSD_INT"
        values = values.map{|x| RbVmomi::BasicTypes::Int.new(x.to_i)}
      end
      if type.typeName == "XSD_BOOLEAN"
        values = values.map{|x| (x =~ /(true|True|1|yes|Yes)/) != nil}
      end
      if type.is_a?(PBM::PbmCapabilityGenericTypeInfo) && type.genericTypeName == "VMW_RANGE"
        if values.length != 2
          err "#{name} is a range, need to specify 2 values"
        end
        value = PBM::PbmCapabilityTypesRange(:min => values[0], :max => values[1])
      elsif values.length == 1
        value = values.first
      else
        err "Value malformed: #{value_str}"
      end

      {
        :id => {
          :namespace => ns,
          :id => id
        },
        :constraint => [{
                            :propertyInstance => [{
                                                      :id => id,
                                                      :value => value
                                                  }]
                        }]
      }
    end
  end

  def datacenter
    @dc ||= vim.serviceInstance.find_datacenter(resource[:datacenter])
  end

  def cluster
    datacenter.find_compute_resource(resource[:cluster])
  end

  def profile
    @profile ||= exiting_profiles.find {|x| x.name == resource[:name]}
  end

  def pbm
    @pbm ||= vim.pbm
  end

  def pbm_manager
    @pbm_manager ||= pbm.serviceContent.profileManager
  end

  def vsan_cluster_config
    vsan.vsanClusterConfigSystem.VsanClusterGetConfig(:cluster => cluster)
  end

end
