#!/opt/puppet/bin/ruby

require 'rbvmomi/vim'
require 'rbvmomi/pbm'

PBM = RbVmomi::PBM

class RbVmomi::VIM
  def pbm
    @pbm ||= PBM.connect self, :insecure => true
  end

  def pbm= x
    @pbm = nil
  end
end
