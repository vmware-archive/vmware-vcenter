# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')
require 'rbvmomi'
Puppet::Type.type(:esx_portgroup).provide(:esx_portgroup, :parent => Puppet::Provider::Vcenter) do
  @doc = "Manages vSwitch Portgroups."
	def create
    	Puppet.debug "Entered in create portgroup method."
		begin
    		create_port_group 
		rescue Exception => excep
			Puppet.err excep.message
		end
  	end

	def destroy
		Puppet.debug "Entered in destroy portgroup method."
		begin
			remove_port_group
		rescue Exception => excep
    		Puppet.err excep.message
		end
  	end

	def exists?
		Puppet.debug "Entered in exists method."
		#find_portgroup ? true : false
		check_portgroup_existance == true
    	#find_port_group == true
	end

    # vlanid property getter method.
	def vlanid
		Puppet.debug "Retrieving vlan Id associated to the specified portgroup."
		begin
			find_host
		    @networksystem=@host.configManager.networkSystem
			portg=find_portgroup
			vlanid=portg.spec.vlanId					
			if (vlanid != resource[:vlanid].to_i)
				return "false"
			elsif (vlanid == resource[:vlanid].to_i)
				return resource[:vlanid]
			end
		rescue Exception => excep
			Puppet.err excep.message
		end
	end
	
	# vlanid property setter method.
	def vlanid=(value)
		Puppet.debug "Updating vlan Id associated to the specified portgroup."
		begin
			find_host
    		@networksystem=@host.configManager.networkSystem
			portg=find_portgroup
			if (find_vswitch == false)
				raise Puppet::Error, "Unable to find the vSwitch " + resource[:vswitch]
			end	
    	    hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => portg.spec.policy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitch])
    	    @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)
    	rescue Exception => excep
			Puppet.err excep.message
		end
	end

	#mtu getter
	def mtu
    	Puppet.debug "Retrieving mtu on portgroup"
		begin
		find_host
		@networksystem=@host.configManager.networkSystem
        vnics=@networksystem.networkInfo.vnic

        for vnic in (vnics)
 	       if (vnic.portgroup && resource[:name] == vnic.portgroup)
			mtuonportgroup = vnic.spec.mtu
			if (mtuonportgroup != resource[:mtu].to_i)
				return "false"
			else
				return resource[:mtu]
			end
			end	
		end
			return resource[:mtu]

        rescue Exception => excep
            Puppet.err excep.message
        end
	end

	#mtu setter
	Puppet.debug "Updating mtu of specified portgroup."
	def mtu=(value)
		begin
			setupmtu
	    rescue Exception => excep
            Puppet.err excep.message
        end
	end

	def checkbeacon
    	Puppet.debug "Retrieving checkbeacon on portgroup"
		begin
        	find_host
	        @networksystem=@host.configManager.networkSystem
    	    mypg=find_portgroup
        	if (mypg.spec.policy.nicTeaming.failureCriteria != nil)			
	           	checkbeaconpg = mypg.spec.policy.nicTeaming.failureCriteria.checkBeacon
				if (checkbeaconpg != nil)
					return checkbeaconpg.to_s
				elsif (checkbeaconpg == nil)
					return nil
				end
    	    else
        	    Puppet.debug "failback is nil on pg so need to change"
            	return nil
	        end
			return nil
        rescue Exception => excep
            Puppet.err excep.message
        end
	end

	def checkbeacon=(value)
		Puppet.debug "Updating checkbeacon flag of specified portgroup."
		begin
			set_checkbeacon
        rescue Exception => excep
            Puppet.err excep.message
        end
	end

	def failback
	    Puppet.debug "Retrieving failback on portgroup"
		begin
    	    find_host
        	@networksystem=@host.configManager.networkSystem
	        mypg=find_portgroup
    	    if (mypg.spec.policy.nicTeaming.rollingOrder != nil)
        	    failbackorderonpg = mypg.spec.policy.nicTeaming.rollingOrder
            	if ( resource[:failback] == :Yes && failbackorderonpg == false)
					return resource[:failback]
				elsif (resource[:failback] == :Yes && failbackorderonpg == true)
					return "needtochange"
        	    elsif(resource[:failback] == :No && failbackorderonpg == true)
            		return resource[:failback]
	            elsif(resource[:failback] == :No && failbackorderonpg == false)
					return "needtochange"
        	    end
	        else
        	    return "needtochange"
	        end
        rescue Exception => excep
            Puppet.err excep.message
        end

	end

	def failback=(value)
		Puppet.debug "Updating failback status flag of specified portgroup."
		begin
		set_failback
        rescue Exception => excep
            Puppet.err excep.message
        end
	end

	def overridefailoverorder
		Puppet.debug "Retrieving override failover order on port group"
		begin
		find_host
        @networksystem=@host.configManager.networkSystem
		mypg=find_portgroup
		if (mypg.spec.policy.nicTeaming.nicOrder != nil)
			nicorderonpg = mypg.spec.policy.nicTeaming.nicOrder
			if ( resource[:overridefailoverorder] == :Enabled)
					acitvenicsonpg = mypg.spec.policy.nicTeaming.nicOrder.activeNic	
					standbynicsonpg = mypg.spec.policy.nicTeaming.nicOrder.standbyNic	
					#return {"activenic" => acitvenicsonpg, "standbynic" => standbynicsonpg}

					nicorderpolicy = resource[:nicorderpolicy ]
					activenic = nicorderpolicy ['activenic']
					standbynic = nicorderpolicy ['standbynic']
					if (acitvenicsonpg != activenic || standbynicsonpg != standbynic)
						{"activenic" => existing_activenic, "standbynic" => existing_standbynic}
						return "needtochange"
					elsif (acitvenicsonpg == activenic && standbynicsonpg == standbynic)
						return "Enabled"
					end
			elsif(resource[:overridefailoverorder] == :Disabled)
					return "Enabled"
			end
		else
			return "needtochange"
		end
        rescue Exception => excep
            Puppet.err excep.message
        end

   end

 	def overridefailoverorder=(value)
		Puppet.debug "Updating override failover order of specified portgroup."
		begin
			setoverridepolicy
        rescue Exception => excep
            Puppet.err excep.message
        end
	end

    # vmotion property getter method.
	def vmotion
		Puppet.debug "Retrieving vmotion status flag of specified portgroup."
		begin
			myportgroup = find_portgroup
			ports = myportgroup.port
			if (ports !=nil)
				if ( myportgroup.port[0] != nil)	
					type=myportgroup.port[0].type
					if (type == "host")
						#if it is a VMkernel port group then need to change the vmotion flag as per given by user
						return "needtochange"
					else
						#return the same value as given by user
						return resource[:vmotion]
					end
				else
					return resource[:vmotion]
				end
		
			end
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

     # vmotion property setter method.
	def vmotion=(value)
		Puppet.debug "Updating vmotion status flag of specified portgroup."
		begin
		setupvmotion	
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	#ipsettings property getter method.
	def ipsettings
    	Puppet.debug "Retrieving ip configuration of specified portgroup."
		begin
			find_host
    	    @networksystem=@host.configManager.networkSystem
        	vnics=@networksystem.networkInfo.vnic

        	for vnic in (vnics)
	            if (vnic.portgroup && resource[:name] == vnic.portgroup)
	                if (resource[:ipsettings] == :static)
    	                ipaddressonportgroup = vnic.spec.ip.ipAddress
        	            subnetmaskonportgroup = vnic.spec.ip.subnetMask
  				        if (ipaddressonportgroup != resource[:ipaddress] || subnetmaskonportgroup != resource[:subnetmask])
          					return "false"
				        elsif  (ipaddressonportgroup == resource[:ipaddress] && subnetmaskonportgroup == resource[:subnetmask])
        				    return resource[:ipsettings]
							#return same as manifest file  because the port group has same values hence no need to go into setter
            			end
                	elsif (resource[:ipsettings] == :dhcp)
	         			dhcpflagonportgroup = vnic.spec.ip.dhcp
        	    		if (dhcpflagonportgroup == false)
              				return "false"
            			elsif (dhcpflagonportgroup == true)
              				return "automatic"
            			end
                	end
          		end
      		end			
			return "false"
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	# ipsettings property setter method.
	def ipsettings=(value)
    	Puppet.debug "Updating ip configuration of specified port group"
		begin
			find_host
    	    @networksystem=@host.configManager.networkSystem
        	vnics=@networksystem.networkInfo.vnic
        	@vmotionsystem = @host.configManager.vmotionSystem

        	for vnic in (vnics)
	        	if (vnic.portgroup && resource[:name] == vnic.portgroup)
					# Select vnic for vmotion first to update ip configuration
					vnicdevice=vnic.device
					@vmotionsystem.SelectVnic(:device => vnicdevice)

	            	if (resource[:ipsettings] == :static)
						if (resource[:ipaddress] == nil || resource[:subnetmask] == nil)
					    	raise Puppet::Error, "ipaddress and subnetmask are required in case of static IP configuration."
						elsif( resource[:ipaddress].length == 0 || resource[:subnetmask].length == 0)
							raise Puppet::Error, "ipaddress and subnetmask are required in case of static IP configuration."
						end
                    	ipconfiguration=RbVmomi::VIM.HostIpConfig(:dhcp => 0, :ipAddress => resource[:ipaddress], :subnetMask => resource[:subnetmask])
	                    @vmotionsystem.UpdateIpConfig(:ipConfig => ipconfiguration)
    	            elsif (resource[:ipsettings] == :dhcp)
						ipconfiguration = RbVmomi::VIM.HostIpConfig(:dhcp => 1)
                    	@vmotionsystem.UpdateIpConfig(:ipConfig => ipconfiguration)
	        		end
        		end
			end
			return "true"
       rescue Exception => excep
            Puppet.err excep.message
       end
	end


	# Get the traffic shapping policy.
	def traffic_shaping_policy
    	Puppet.debug "Retrieving the traffic shaping policy of specified port group."
		begin
    		@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			find_host
		    @networksystem=@host.configManager.networkSystem
			portg=find_portgroup
				enabled = portg.computedPolicy.shapingPolicy.enabled
				avgbw = portg.computedPolicy.shapingPolicy.averageBandwidth
				pkbw = portg.computedPolicy.shapingPolicy.peakBandwidth
				burstsize = portg.computedPolicy.shapingPolicy.burstSize

				if (resource[:traffic_shaping_policy] == :Enabled)
					
					if (enabled == true && avgbw/1000 == resource[:averagebandwidth].to_i && pkbw/1000 == resource[:peakbandwidth].to_i && burstsize/1024 == resource[:burstsize].to_i) 
						return "Enabled"
							
					elsif (enabled == false || avgbw/1000 != resource[:averagebandwidth].to_i || pkbw/1000 != resource[:peakbandwidth].to_i || burstsize/1024 != resource[:burstsize].to_i)
						return "needtochange"
					end
				elsif (resource[:traffic_shaping_policy] == :Disabled)
					if (enabled == false)
						return "Disabled"
					elsif (enabled == true)
						return "Enabled"
					end
				end
       rescue Exception => excep
            Puppet.err excep.message
       end
 	end

  # Set the traffic shapping policy
	def traffic_shaping_policy=(value)
    	Puppet.debug "Updating the traffic shaping policy of specified port group."
		begin
			traffic_shaping
    		return true
    	rescue Exception => excep
            Puppet.err excep.message
    	end
  end

  private
    # Private method to find the datacenter.
	def walk_dc(path=resource[:path])
		begin
	    @datacenter = walk(path, RbVmomi::VIM::Datacenter)
			if @datacenter.nil?
    			raise Puppet::Error, "No datacenter  in path: #{path}" unless @datacenter
			end
    		@datacenter
	    rescue Exception => excep
    		Puppet.err excep.message
	    end
	end

    # Private method to find the portgroup.
	def check_portgroup_existance
		Puppet.debug "Entering find_port_group"
		begin
			find_host
    	    @networksystem=@host.configManager.networkSystem
        	@pg = @networksystem.networkInfo.portgroup
	        for portg in (@pg) do
                availablepgs = portg.spec.name
                if (availablepgs == resource[:name])
                	return true
                end
        	end
        	#return false if portgroup not found
        	return false
	    rescue Exception => excep
    		Puppet.err excep.message
	    end
	end

    # Private method to set the traffic shaping policy on the port group.
	def traffic_shaping
		Puppet.debug "Entering traffic_shaping"
		find_host
        @networksystem=@host.configManager.networkSystem
        @pg = @networksystem.networkInfo.portgroup
        for portg in (@pg) do
            availablepgs = portg.spec.name
            if (availablepgs == resource[:name])
        		if ( resource[:traffic_shaping_policy] == :Enabled )
		            avgbandwidth = resource[:averagebandwidth].to_i * 1000	
        		    peakbandwidth =  resource[:peakbandwidth].to_i * 1000
		            burstsize = resource[:burstsize].to_i * 1024
        		    enabled = 1		            

        		    hostnetworktrafficshapingpolicy =  RbVmomi::VIM.HostNetworkTrafficShapingPolicy(:averageBandwidth => avgbandwidth, :burstSize => burstsize, :enabled => enabled, :peakBandwidth => peakbandwidth)

            		hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:shapingPolicy => hostnetworktrafficshapingpolicy)

					actualspec = portg.spec
					if (actualspec.policy != nil )
						actualspec.policy.shapingPolicy = hostnetworktrafficshapingpolicy
					else
						actualspec.policy = hostnetworkpolicy
					end

        	        @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => actualspec)

		        elsif ( resource[:traffic_shaping_policy] == :Disabled)
					enabled = 0
        		    hostnetworktrafficshapingpolicy =  RbVmomi::VIM.HostNetworkTrafficShapingPolicy(:enabled => enabled)
        		    hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:shapingPolicy => hostnetworktrafficshapingpolicy)
					actualspec = portg.spec
					actualspec.policy = hostnetworkpolicy
	                @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => actualspec)
            	end
        	end
        end
        return true
	end


  	# Private method to find the vSwitch
	def find_vswitch
		host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
	    networksystem=host.configManager.networkSystem
    	vswitches = networksystem.networkInfo.vswitch

	    for vswitch in (vswitches) do
    	  availablevswitch = vswitch.name
	      if (availablevswitch == resource[:vswitch])
    	    return true
	      end
    	end
	    #return false if vSwitch not found
    	return false
	  end

    # Private method to create the portgroup.
	def create_port_group
		Puppet.debug "Entering Create Port Group method."
			find_host
        	@networksystem=@host.configManager.networkSystem
			if (find_vswitch == false)
				raise Puppet::Error, "Unable to find the vSwitch " + resource[:vswitch]
			end	
			
			hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy()
        	hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => name, :policy => hostnetworkpolicy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitch])

	        @networksystem.AddPortGroup(:portgrp => hostportgroupspec)


			if (resource[:traffic_shaping_policy] !=nil )
				traffic_shaping
			end
	
			if (resource[:failback] !=nil )
				set_failback
			end

			if (resource[:overridefailoverorder] !=nil )
				setoverridepolicy
			end
			if (resource[:checkbeacon]!= nil)
				set_checkbeacon
			end

			if (resource[:type] == :VMkernel)
				Puppet.debug "Entering type VMkernel"

				if (resource[:ipsettings] == :static)
					upip = RbVmomi::VIM.HostIpConfig(:dhcp => 0, :ipAddress => resource[:ipaddress], :subnetMask => resource[:subnetmask])
					hostvirtualnicspec =  RbVmomi::VIM.HostVirtualNicSpec(:ip => upip)
					@networksystem.AddVirtualNic(:portgroup => resource[:name], :nic => hostvirtualnicspec)	
				elsif (resource[:ipsettings] == :dhcp)
					upip = RbVmomi::VIM.HostIpConfig(:dhcp => 1)
					hostvirtualnicspec =  RbVmomi::VIM.HostVirtualNicSpec(:ip => upip)
					@networksystem.AddVirtualNic(:portgroup => resource[:name], :nic => hostvirtualnicspec)	
				else
					upip = RbVmomi::VIM.HostIpConfig(:dhcp => 1)
					hostvirtualnicspec =  RbVmomi::VIM.HostVirtualNicSpec(:ip => upip)
					@networksystem.AddVirtualNic(:portgroup => resource[:name], :nic => hostvirtualnicspec)	
				end

	
				if (resource[:vmotion] !=nil )
					setupvmotion
				end

				if (resource[:mtu] !=nil )
					setupmtu
				end

			end
			Puppet.notice "Successfully created a portgroup {" + resource[:name] + "}"
	end

	def set_failback
    # Private method to set the failback on the port group.
		Puppet.debug "Entering set_failback"
        find_host
		mypg=find_portgroup
        @networksystem=@host.configManager.networkSystem

	    if ( resource[:failback] != nil)
        	if ( resource[:failback] == :Yes )
				failbk = false
            elsif (resource[:failback] == :No)
                    failbk = true
            end
            hostnicteamingpolicy = RbVmomi::VIM.HostNicTeamingPolicy(:rollingOrder => failbk)
            hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:nicTeaming=> hostnicteamingpolicy)

            actualspec = mypg.spec

			if (actualspec.policy != nil )
				if (actualspec.policy.nicTeaming !=nil)
					actualspec.policy.nicTeaming.rollingOrder = failbk
				else
            		#hostnicteamingpolicy = RbVmomi::VIM.HostNicTeamingPolicy(:rollingOrder => failbk)
		            #hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:nicTeaming=> hostnicteamingpolicy)
    	        	actualspec.policy = hostnetworkpolicy
				end
			else	
    	        actualspec.policy = hostnetworkpolicy
			end

            @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => actualspec)
		end
        return true
	end

	def set_checkbeacon
    # Private method to set the failback on the port group.
		Puppet.debug "Entering set_checkbeacon"
        find_host
        mypg=find_portgroup
        @networksystem=@host.configManager.networkSystem

        if ( resource[:checkbeacon] != nil)
			customfailurecriteria = RbVmomi::VIM.HostNicFailureCriteria(:checkBeacon => resource[:checkbeacon])
            hostnicteamingpolicy = RbVmomi::VIM.HostNicTeamingPolicy(:failureCriteria => customfailurecriteria)
            hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:nicTeaming=> hostnicteamingpolicy)

            actualspec = mypg.spec
			if (actualspec.policy != nil )
				if (actualspec.policy.nicTeaming !=nil)
					actualspec.policy.nicTeaming.failureCriteria=customfailurecriteria
				else
            		actualspec.policy = hostnetworkpolicy
					
				end
			else
            actualspec.policy = hostnetworkpolicy
			end

            @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => actualspec)
        end
        return true
	end

    # Private method to enable/disable the vmotion.
	def setupvmotion
		Puppet.debug "Entering setup vmotion method."
		find_host
		@networksystem=@host.configManager.networkSystem

		if (resource[:type] == :VMkernel)
    		@vmotionsystem = @host.configManager.vmotionSystem
		    vnics=@networksystem.networkInfo.vnic

			#enabling vmotion	
			if (resource[:vmotion] == :Enabled)
			  	for vnic in (vnics)
        			if (vnic.portgroup && resource[:name] == vnic.portgroup)
            			vnicdevice=vnic.device
	        		end
    			end
      			@vmotionsystem.SelectVnic(:device => vnicdevice)
			end
			#disabling vmotion
			if (resource[:vmotion] == :Disabled)
				@vmotionsystem.DeselectVnic()
			end

		end
	end

    def setupmtu
        Puppet.debug "Entering setupmtu"
        find_host
        @networksystem=@host.configManager.networkSystem
        vnics=@networksystem.networkInfo.vnic

        #enabling mtu
        if (resource[:mtu] && resource[:mtu].to_i > 1500 && resource[:mtu].to_i<=9000)
            for vnic in (vnics)
                if (vnic.portgroup && resource[:name] == vnic.portgroup)
                    vnicdevice=vnic.device
                    hostvirtualnicspec = RbVmomi::VIM.HostVirtualNicSpec(:mtu => resource[:mtu])
                    @networksystem.UpdateVirtualNic(:device => vnicdevice, :nic => hostvirtualnicspec)
                end
            end
        end
    end


	def setoverridepolicy 
        Puppet.debug "Entering setoverridepolicy"
		activenic = nil
		standbynic = nil
		find_host
		@networksystem=@host.configManager.networkSystem
		mypg=find_portgroup
	    actualspec = mypg.spec

		if (resource[:overridefailoverorder] == :Enabled)
			nicorderpolicy = resource[:nicorderpolicy ]
			if(nicorderpolicy != nil)
			   	if(nicorderpolicy['activenic'] != nil &&  nicorderpolicy['activenic'].length > 0)
        			activenic = nicorderpolicy ['activenic']
				end
				if(nicorderpolicy ['standbynic'] != nil && nicorderpolicy ['standbynic'].length > 0)
			        standbynic = nicorderpolicy ['standbynic']
      			end
    		end

			hostnicorderpolicy = RbVmomi::VIM::HostNicOrderPolicy(:activeNic => activenic, :standbyNic => standbynic)
		elsif (resource[:overridefailoverorder] == :Disabled)
			hostnicorderpolicy = nil
		end

    	hostnicteamingpolicy = RbVmomi::VIM.HostNicTeamingPolicy(:nicOrder => hostnicorderpolicy)
        hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:nicTeaming=> hostnicteamingpolicy)
		
		if (actualspec.policy != nil )
			if (actualspec.policy.nicTeaming != nil)
				actualspec.policy.nicTeaming.nicOrder = hostnicorderpolicy
			else
				actualspec.policy = hostnetworkpolicy
			end
		else
			actualspec.policy = hostnetworkpolicy
		end

		@networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => actualspec)
	end

    # Private method to remove the portgroup.
	def remove_port_group
        Puppet.debug "Entering remove_port_group"
		find_host
        @networksystem=@host.configManager.networkSystem

		if (resource[:type] == :VMkernel)
            vnics=@networksystem.networkInfo.vnic

            for vnic in (vnics)
            	if (vnic.portgroup && resource[:name] == vnic.portgroup)
                	vnicdevice=vnic.device
                end
            end

		@networksystem.RemoveVirtualNic(:device => vnicdevice)
		end

        @networksystem.RemovePortGroup(:pgName => resource[:name])

        Puppet.notice "Successfully removed the portgroup {" + resource[:name] + "}"
	end
	
	# Private method to find the host.
	def find_host
		begin
			@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			if @host.nil?
				raise Puppet::Error, "No Host in datacenter #{walk_dc}" unless @host
			end
			@host
		rescue Exception => excep
			Puppet.err excep.message
		end
	end

	def find_portgroup
	    find_host
        @networksystem=@host.configManager.networkSystem
        @pg = @networksystem.networkInfo.portgroup
        for portg in (@pg) do
	        availablepgs = portg.spec.name
    	    if (availablepgs == resource[:name])
				return portg	
			end
		end	
	end
end


