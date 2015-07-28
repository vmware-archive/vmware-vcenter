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
        connection_state = ( host.summary.runtime.dasHostState.state || '' )
        if connection_state == 'fdmUnreachable' || resource[:force]
          task_status = host.ReconfigureHostForDAS_Task!
          while (task_status.info.state.match(/running|queued/i))
            sleep(10)
          end
        end
        Puppet.notice 'Reconfiguing HA Agent completed.'
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

