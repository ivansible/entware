# ivansible.wrt_sshtun

[![Github Test Status](https://github.com/ivansible/wrt-sshtun/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/wrt-sshtun/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/wrt-sshtun.svg?branch=master)](https://travis-ci.org/ivansible/wrt-sshtun)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.wrt__sshtun-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/wrt_sshtun/)

This role configures a local service on Keenetic Entware that retries
SSH client connections to a remote SSH server and sets up a SSH tunnel.
The server(s) can be configured by the role
[srv_sshtun](https://github.com/ivandeex/ivantory/tree/master/roles/srv_sshtun#readme).


## Requirements

None


## Variables

    wrt_sshtun_ssh_port: 22
Default SSH port on server to connect to. Peers can override it.
Note: there is no default host name, it must be specified for every peer.

    wrt_sshtun_ssh_user: ~
Default SSH user name. Peers can override it.
SSH client will use this user name to initiate the tunnel.
If user is not configured per-peer or globally, the peer will be skipped.

    wrt_sshtun_ssh_key: ~
The SSH client will use this private key to initiate the tunnel.
The role will install and use a private key if the setting is not empty.
Peers can override this default.

    wrt_sshtun_proxy: ~
This optional setting commands SSH clients to connect via proxy.
For example, `http://proxy.com:3128` will use HTTP proxy on given host/port
or `socks5://:1080` will use SOCKS5 proxy on the given localhost port.
No proxy will be used if this is empty.
Peers can override this default.

    wrt_sshtun_socks_port: 0
The tunnel client will command SSH to open a socks proxy on this remote port.
This setting is required for remote peer to properly detect if tunnel is down.
Peers can override this default.

    wrt_sshtun_forward_ports: ~
This is an optional list of port forwarding descriptors,
where each descriptor has the following fields:
  - `comment` - optional comment
  - `local`   - localhost `port` or tuple `host:port` to forward
  - `remote`  - listening port on remote peer
Peers can override this list.

    wrt_sshtun_gw_ipv4: ~
    wrt_sshtun_gw_ipv6: ~
The local connection helper script configures local and remote IPv4/IPv6
addresses on the tunnel on the local tunnel device. These two settings
define point-to-point subnets without the last IP address nibble.
The actual nibble will be appended to form the addresses.
The _remote_ (server) address will end in `1`, _local_ (client) one with `2`.
For example, if `wrt_sshtun_gw_ipv4` is `192.168.55`, the IPv4 addresses
of the local and remote endpoint will be `192.168.55.2` and `192.168.55.1`.

These settings define default subnets for all peers, but peers can override these.

    wrt_sshtun_local_tun: 1
    wrt_sshtun_remote_tun: 1
Routes and addresses will be applied to these tunnel interfaces on
the local and remote ends. The actual device names will be "tunN".
The `remote_tun` number can be overridden per-peer,
but `local_tun` is global for all peers and cannot be customized.

    wrt_sshtun_command_path: /usr/local/sbin/sshtun-serv
The path to the connection helper script on the remote peer that configures
tunnel device on the remote end. This script will be invoked upon connection
with single argument `up`.

    wrt_sshtun_sleep_interval: 60
Time in seconds to wait before next login attempt if current login has failed.

    wrt_sshtun_forward_ports: ~
This is an optional list of port forwarding descriptors,
where each descriptor has the following fields:

    wrt_sshtun_servers: [...]
A list of SSH server descriptors (peers).
If this list is empty, the role will be skipped.
Every descriptor has the following required fields:
  - `name` - peer name, the connection will be registered with SSH client
             under this alias; the peer will be skipped if this one is empty;
  - `ssh_host` - ssh server host name.

The following peer fields are optional and allow to override respective globals:
`ssh_port`, `ssh_user`, `ssh_key`, `proxy`, `remote_tun`, `gw_ipv4`, `gw_ipv6`,
`socks_port`, `forward_ports`.

The fields `strict_host_checks`, `keyscan_workaround` and `host_key` are
all optional and deal with SSH host key checking. By default strict host
checks depend on proxy setting: If proxy is configured, strict checking is
disabled and SSH client will accept host key upon first connect.
If proxy is not configured, strict checking is turned on, and the role
will register host key in advance before a first SSH connection.
If the `host_key` field is not empty, the host key will be taken from there.
If `host_key` is not provided, the role will attempt a host key scan from the
controller machine. If the scan fails, the role will abort. However, if the
`keyscan_workaround` flag is true (this flag is optional and defaults to the
`wrt_sshtun_keyscan_workaround` global flag), the role will not abort but
issue a warning and disable strict checking so that SSH client will record
host key upon first connect. The `host_key` and `strict_host_checks` settings
are per-peer only and have no global defaults.

    wrt_sshtun_default_server: default
The role creates configurations for all configured server but sets up
a symbolic link to the active server under `/opt/etc/sshtun` entware directory.
You can switch between configured servers as follows: change the link and
restart the sshtun client service: `/opt/etc/init.d/S45sshtun restart`.


## Tags

- `wrt_sshtun_packages` -- install packages
- `wrt_sshtun_netfilter` -- create helper for netfilter
- `wrt_sshtun_service` -- setup service
- `wrt_sshtun_scripts` -- create helper scripts for all peers
- `wrt_sshtun_peers` -- configure ssh peers
- `wrt_sshtun_ssh` -- configure ssh client for every peer
- `wrt_sshtun_config` -- update configuration for every peer
- `wrt_sshtun_all` -- all tasks


## Dependencies

- `wrt_net` -- inherit netfilter task and settings


## Example Playbook

    - hosts: keenetic
      roles:
         - role: ivansible.wrt_sshtun
           wrt_sshtun_servers:
             - name: default
               ssh_host: myserver.com
               ssh_user: ubuntu
               socks_port: 21080
               gw_ipv4: 192.168.11
               gw_ipv6: fd00:11
           wrt_sshtun_local_tun: 1
           wrt_sshtun_remote_tun: 2


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
