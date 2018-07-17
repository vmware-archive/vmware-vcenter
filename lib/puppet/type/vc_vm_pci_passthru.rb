Puppet::Type.newtype(:vc_vm_pci_passthru) do
  @doc = "Enable / Disable VM PCI passthrough configuration."

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:datacenter) do
  end

end

