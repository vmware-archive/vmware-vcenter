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
    	find_port_group == true
	end

    # vlanid property getter method.
	def vlanid
		Puppet.debug "Retrieving vlan Id associated to the given portgroup."
		begin
			find_host
		    @networksystem=@host.configManager.networkSystem
    		@pg = @networksystem.networkInfo.portgroup
	    	for portg in (@pg) do
    	    	availablepgs = portg.spec.name
        		if (availablepgs == resource[:name])
					vlanid=portg.spec.vlanId
					Puppet.debug "#{vlanid}"
					return vlanid
				end
			end
		rescue Exception => excep
			Puppet.err excep.message
		end
	end
	
	# vlanid property setter method.
	def vlanid=(value)
		Puppet.debug "Updating vlan Id associated to the given portgroup."
		begin
			find_host
    		@networksystem=@host.configManager.networkSystem
	    	@pg = @networksystem.networkInfo.portgroup
	    	for portg in (@pg) do
    	    	availablepgs = portg.spec.name
	    	    if (availablepgs == resource[:name])
			if (find_vswitch == false)
				raise Puppet::Error, "Unable to find the vSwitch " + resource[:vswitch]
			end	
		    	    hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => portg.spec.policy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitch])
        	    	@networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)
				end
			end
    	rescue Exception => excep
			Puppet.err excep.message
		end
	end

    # vmotion property getter method.
	def vmotion
		Puppet.debug "Retrieving vmotion status flag of given portgroup."
		begin
			return "needtochange"
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

     # vmotion property setter method.
	def vmotion=(value)
		Puppet.debug "Updating vmotion status flag of given portgroup."
		begin
		setupvmotion	
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	#ipsettings property getter method.
	def ipsettings
    	Puppet.debug "Retrieving ip configuration of given portgroup."
		begin
			find_host
    	    @networksystem=@host.configManager.networkSystem
        	vnics=@networksystem.networkInfo.vnic

        	for vnic in (vnics)
	            if (vnic.portgroup && resource[:name] == vnic.portgroup)
	                if (resource[:ipsettings] == :static)
    	                ipaddressonportgroup = vnic.spec.ip.ipAddress
        	            subnetmaskonportgroup = vnic.spec.ip.subnetMask
            	        Puppet.debug "ipaddressonportgroup=#{ipaddressonportgroup}, subnetMask=#{subnetmaskonportgroup}"
  				        if (ipaddressonportgroup != resource[:ipaddress] || subnetmaskonportgroup != resource[:subnetmask])
          					return "false"
				        elsif  (ipaddressonportgroup == resource[:ipaddress] && subnetmaskonportgroup == resource[:subnetmask])
        				    return "manual"
							#return same as manifest file i.e  manual because the port group has same values hence no need to go into setter
            			end
                	elsif (resource[:ipsettings] == :dhcp)
	         			dhcpflagonportgroup = vnic.spec.ip.dhcp
    	       			Puppet.debug "dhcpflagonportgroup=#{dhcpflagonportgroup}"
        	    		if (dhcpflagonportgroup == false)
              				return "false"
            			elsif (dhcpflagonportgroup == true)
              				return "automatic"
            			end
                	end
          		end
      		end
			Puppet.debug "coming falsely here"
			return "false"
        rescue Exception => excep
            Puppet.err excep.message
		end
	end

	# ipsettings property setter method.
	def ipsettings=(value)
    	Puppet.debug "Updating ip configuration of given port group"
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
						Puppet.debug "Setting static IP on portgroups."
	                    @vmotionsystem.UpdateIpConfig(:ipConfig => ipconfiguration)
    	            elsif (resource[:ipsettings] == :dhcp)
   	    	        	Puppet.debug "Setting DHCP on portgroup."
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
    	Puppet.debug "Retrieving the traffic shaping policy of given port group."
		begin
    		@host = vim.searchIndex.FindByDnsName(:datacenter => walk_dc, :dnsName => resource[:host], :vmSearch => false)
			find_host
		    @networksystem=@host.configManager.networkSystem
		    @pg = @networksystem.networkInfo.portgroup
		    for portg in (@pg) do
    			availablepgs = portg.spec.name
		        if (availablepgs == resource[:name])
					enabled = portg.computedPolicy.shapingPolicy.enabled
					avgbw = portg.computedPolicy.shapingPolicy.averageBandwidth
					pkbw = portg.computedPolicy.shapingPolicy.peakBandwidth
					burstsize = portg.computedPolicy.shapingPolicy.burstSize
					Puppet.debug "existing portgroup ts enabled = #{enabled}"

					if (resource[:traffic_shaping_policy] == :Enabled)
					
						if (enabled == true && avgbw == resource[:averagebandwidth] && pkbw == resource[:peakbandwidth] && burstsize == resource[:burstsize]) 
							return "Enabled"
						elsif (enabled == false || avgbw != resource[:averagebandwidth] || pkbw != resource[:peakbandwidth] || burstsize != resource[:burstsize])
							return "needtochange"
						end
					elsif (resource[:traffic_shaping_policy] == :Disabled)
						if (enabled == false)
							return "Disabled"
						elsif (enabled == true)
							return "Enabled"
						end
					end
					
        		end
  			end
       rescue Exception => excep
            Puppet.err excep.message
       end
 	end

  # Set the traffic shapping policy
	def traffic_shaping_policy=(value)
    	Puppet.debug "Updating the traffic shaping policy of given port group."
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
	def find_port_group
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
        		    enabled = "true"
		            Puppet.debug "#{avgbandwidth},#{peakbandwidth},#{burstsize}"

        		    hostnetworktrafficshapingpolicy =  RbVmomi::VIM.HostNetworkTrafficShapingPolicy(:averageBandwidth => avgbandwidth, :burstSize => burstsize, :enabled => enabled, :peakBandwidth => peakbandwidth)

            		hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy(:shapingPolicy => hostnetworktrafficshapingpolicy)
					if (find_vswitch == false)
						raise Puppet::Error, "Unable to find the vswitch " + resource[:vswitch]
					end	
    	            hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => hostnetworkpolicy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitch])
        	        @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)

		        elsif ( resource[:traffic_shaping_policy] == :Disabled)
        		    hostnetworkpolicy = RbVmomi::VIM.HostNetworkPolicy()
					if (find_vswitch == false)
						raise Puppet::Error, "Unable to find the vswitch " + resource[:vswitch]
					end	
                	hostportgroupspec = RbVmomi::VIM.HostPortGroupSpec(:name => resource[:name], :policy => hostnetworkpolicy, :vlanId => resource[:vlanid], :vswitchName => resource[:vswitch])
	                @networksystem.UpdatePortGroup(:pgName => resource[:name], :portgrp => hostportgroupspec)
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

			traffic_shaping
			if ( resource[:type] == "VMkernel" )
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

				setupvmotion
			end
			Puppet.notice "Successfully created portGroup " + resource[:name]
	end

    # Private method to enable/disable the vmotion.
	def setupvmotion
		Puppet.debug "Inside setup vmotion method."
		find_host
		@networksystem=@host.configManager.networkSystem
    	@vmotionsystem = @host.configManager.vmotionSystem
	    vnics=@networksystem.networkInfo.vnic
	
		Puppet.debug resource[:vmotion]
		if (resource[:vmotion] == :Enabled)
		  	for vnic in (vnics)
        		if (vnic.portgroup && resource[:name] == vnic.portgroup)
            		vnicdevice=vnic.device
        		end
    		end
      		@vmotionsystem.SelectVnic(:device => vnicdevice)
		end
		if (resource[:vmotion] == :Disabled)
			Puppet.debug "setting vmotion flag to disabled"
			@vmotionsystem.DeselectVnic()
		end
	end

    # Private method to remove the portgroup.
	def remove_port_group
        Puppet.debug "Inside remove_port_group"
		find_host
        @networksystem=@host.configManager.networkSystem
        @networksystem.RemovePortGroup(:pgName => resource[:name])

        Puppet.notice "Removed portgroup" + resource[:name]
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
end


