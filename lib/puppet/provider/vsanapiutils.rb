#!/usr/bin/env ruby
"""
Copyright 2016 VMware, Inc.  All rights reserved.

Require a minimum Ruby version of 1.8.7.

This module defines basic helper functions used in the sampe codes
"""

require 'rbvmomi'
# Use require_relative if vsanmgmt.api.rb file is copied to current work dir
require_relative 'vsanmgmt.api'
# Use require if the vsanmgmt.api.rb file is in the ruby lib path
#require 'vsanmgmt.api'

class RbVmomi::VIM::Vsan < RbVmomi::VIM
  VSAN_API_VC_SERVICE_ENDPOINT = '/vsanHealth'
  VSAN_API_ESXI_SERVICE_ENDPOINT = '/vsan'

  def initialize(conn)
    @isVc = conn.serviceContent.about.apiType == 'VirtualCenter'
    @vsanStub = _getVsanStub(conn, @isVc ? VSAN_API_VC_SERVICE_ENDPOINT :
        VSAN_API_ESXI_SERVICE_ENDPOINT)
  end

  # Constuct a stub for VSAN API access using VC or ESXi sessions from  existing
  # stubs. Correspoding VC or ESXi service endpoint is required. VC service
  # endpoint is used as default
  def _getVsanStub(conn, endpoint=VSAN_API_VC_SERVICE_ENDPOINT,
                   version='vim.version.version10')
    vsanStub = RbVmomi::VIM.new(
        :host => conn.host,
        :ns => 'urn:vim25',
        :rev => version,
        :ssl => conn.http.use_ssl?,
        :insecure => conn.http.verify_mode == OpenSSL::SSL::VERIFY_NONE,
        :port => (conn.http.use_ssl? ? 443 : 80),
        :path => endpoint,
    )
    vsanStub.cookie = conn.cookie
    return vsanStub
  end

  def getVsanMos()
    if @isVc
      @vsanMos ||= {
          :vsanDiskManagementSystem => RbVmomi::VIM::VimClusterVsanVcDiskManagementSystem(
              @vsanStub,
              'vsan-disk-management-system'
          ),
          :vsanStrechedClusterSystem => RbVmomi::VIM::VimClusterVsanVcStretchedClusterSystem(
              @vsanStub,
              'vsan-stretched-cluster-system'
          ),
          :vsanClusterConfigSystem => RbVmomi::VIM::VsanVcClusterConfigSystem(
              @vsanStub,
              'vsan-cluster-config-system'
          ),
          :vsanPerformanceManager => RbVmomi::VIM::VsanPerformanceManager(
              @vsanStub,
              'vsan-performance-manager'
          ),
          :vsanClusterHealthSystem => RbVmomi::VIM::VsanVcClusterHealthSystem(
              @vsanStub,
              'vsan-cluster-health-system'
          ),
          :vsanUpgradeSystemEx => RbVmomi::VIM::VsanUpgradeSystemEx(
              @vsanStub,
              'vsan-upgrade-systemex'
          ),
          :vsanSpaceReportSystem => RbVmomi::VIM::VsanSpaceReportSystem(
              @vsanStub,
              'vsan-cluster-space-report-system'
          ),
          :vsanObjectSystem => RbVmomi::VIM::VsanObjectSystem(
              @vsanStub,
              'vsan-cluster-object-system'
          )
      }
    else
      @vsanMos ||= {
          :vsanPerformanceManager => RbVmomi::VIM::VsanPerformanceManager(
              @vsanStub,
              'vsan-performance-manager'
          ),
          :vsanHealthSystem => RbVmomi::VIM::HostVsanHealthSystem(
              @vsanStub,
              'ha-vsan-health-system'
          ),
          :vsanObjectSystem => RbVmomi::VIM::VsanObjectSystem(
              @vsanStub,
              'vsan-object-system'
          )
      }
    end
  end

  def method_missing(method_id, *args, &block)
    if getVsanMos.key?(method_id)
      getVsanMos[method_id]
    else
      super
    end
  end

  def respond_to?(method_id, include_private = false)
    if getVsanMos.key?(method_id)
      true
    else
      super
    end
  end
end

RbVmomi::VIM
class RbVmomi::VIM
  def vsan
    @vsan ||= RbVmomi::VIM::Vsan.new(self)
  end
end

RbVmomi::VIM::Task
class RbVmomi::VIM::Task
  # Convert a VSAN Task to a Task MO binding to VC service
  # @param vsanTask the VSAN Task MO
  # @param stub the stub for the VC API
  def onConnection(conn)
    return RbVmomi::VIM::Task(conn, self._ref)
  end
end
