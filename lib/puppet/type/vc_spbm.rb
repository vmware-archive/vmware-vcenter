Puppet::Type.newtype(:vc_spbm) do
  @doc = "Manage storage poicy based management for virtual machines."

  ensurable

  newparam(:name, :namevar => true) do
    desc "SPBM policy name"
  end

  newparam(:description) do
    desc "SPBM policy description"
  end

  newproperty(:rules) do
    desc "set of rules that needs to be configured in the policy"
  end

  newproperty(:failure_tolerance_method) do
    desc "Replication state"
  end

  newproperty(:host_failures_to_tolerate) do
    desc "Host failures to tolerate"
  end

  newproperty(:stripe_width) do
    desc "Stripe_width"
  end

  newproperty(:force_provisioning) do
    desc "Force provisioning"
  end

  newproperty(:proportional_capacity) do
    desc "Proportional capacity"
  end

  newproperty(:cache_reservation) do
    desc "Cache reservation"
  end

  newparam(:cluster) do
    desc 'Name of the cluster.'
  end

  newparam(:datacenter) do
    desc 'Name of the datacenter.'
  end

end
