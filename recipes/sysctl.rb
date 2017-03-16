# contains the bare minimum sysctl tunings to prevent
# riak from throwing warnings on startup
# This is optional for those with existing
# tuning or wrapper cookbooks
include_recipe 'sysctl::default'

linux_sysctl_params = {
  vm: { swappiness: 0 },
  net: {
    core: {
      somaxconn: 40_000,
      wmem_default: 8_388_608,
      wmem_max: 8_388_608,
      rmem_default: 8_388_608,
      rmem_max: 8_388_608,
      netdev_max_backlog: 10_000
    },
    ipv4: {
      tcp_max_syn_backlog: 40_000,
      tcp_sack: 1,
      tcp_window_scaling: 1,
      tcp_fin_timeout: 15,
      tcp_keepalive_intvl: 30,
      tcp_tw_reuse: 1,
      tcp_moderate_rcvbuf: 1
    }
  }
}

freebsd_sysctl_params = {
  # vm: { swap_enabled: 0 },
  kern: {
    ipc: {
      maxsockbuf: 8_388_608,
      # somaxconn: 40_000,
      # shmmax: 8_388_608
    }
  },
  net: {
    inet: {
      tcp: {
        # sendspace: 8_388_608,
        sendbuf_max: 8_388_608,
        sendbuf_auto: 1,
        # recvspace: 8_388_608,
        recvbuf_max: 8_388_608,
        recvbuf_auto: 1,
        # sack: {
        #   enable: 1
        # },
        # finwait2_timeout: 15,
        # keepintvl: 30,
        # fast_finwait2_recycle: 1,
      }
    }
  }
}

sysctl_params = {
  debian: linux_sysctl_params,
  rhel: linux_sysctl_params,
  fedora: linux_sysctl_params,
  freebsd: freebsd_sysctl_params
}

platform_family = node['platform_family'].to_sym
return unless sysctl_params[platform_family]

Sysctl.compile_attr('', sysctl_params[platform_family]).each do |sysctl_pair|
  param, val = sysctl_pair.split('=')

  sysctl_param param do
    value val
  end
end
