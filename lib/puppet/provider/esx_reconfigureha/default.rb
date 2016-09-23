# Copyright (C) 2013 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcenter')

Puppet::Type.type(:esx_reconfigureha).provide(:esx_reconfigureha, :parent => Puppet::Provider::Vcenter) do
  @doc = "Reconigure HA Agent"
  def create
    begin
      if host == nil
        raise Puppet::Error, "An invalid host name or IP address is entered. Enter the correct host name and IP address."
      else
        Puppet.notice 'Reconfiguring HA Agent'
        connection_state = host.summary.runtime.dasHostState.state if host.summary.runtime.dasHostState
        Puppet.debug("HA connection state for #{resource[:host]} is '#{connection_state}'")
        # The available states can be found here:
        # https://www.vmware.com/support/developer/converter-sdk/conv51_apireference/vim.cluster.DasFdmAvailabilityState.html
        #
        # The states checked below appear to be the only "good" states where HA
        # is functioning correctly. It is not clear that reconfiguring HA can
        # fix all of the other states, but there does not appear to be any harm
        # in running the HA reconfigure task.
        if !%w(connectedToMaster election master).include?(connection_state) || resource[:force] || !host.configStatus.eql?("green")
          Puppet.info("Running HA Reconfigure task for #{resource[:host]}")
          task_status = host.ReconfigureHostForDAS_Task!
          while task_status.info.state.match(/running|queued/i)
            sleep(10)
          end
        end
        Puppet.notice 'Reconfiguring HA Agent completed.'
      end
    rescue Exception => e
      fail "Unable to perform the operation because the following exception occurred: -\n #{e.message}"
    end
  end

  def exists?
    return false
  end

  def destroy
  end

end

