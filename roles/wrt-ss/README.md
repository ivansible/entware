# ivansible.wrt_ss

[![Github Test Status](https://github.com/ivansible/wrt-ss/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/wrt-ss/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/wrt-ss.svg?branch=master)](https://travis-ci.org/ivansible/wrt-ss)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.wrt__ss-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/wrt_ss/)

This role deploys [shadowsocks](https://github.com/shadowsocks/shadowsocks-libev)
client (ss-local) with [v2ray](https://github.com/shadowsocks/v2ray-plugin/)
plugin with websocket transport on Keenetic Entware.


## Requirements

None


## Variables

Main variables are listed below:

    wrt_ss_enable: true
Allows to install shadowsocks, the role is skipped if this flag is `false`.
You may want to disable shadowsocks since v2ray plugin is memory hungry.

    wrt_ss_host: example.com
    wrt_ss_port: 443
    wrt_ss_path: /
Server HTTP connection parameters.

    wrt_ss_password: supersecret
    wrt_ss_method: chacha20-ietf-poly1305
Server encryption parameters. The encryption method is one of:
 - aes-128-gcm, aes-192-gcm, aes-256-gcm,
 - aes-128-cfb, aes-192-cfb, aes-256-cfb,
 - aes-128-ctr, aes-192-ctr, aes-256-ctr,
 - camellia-128-cfb, camellia-192-cfb, camellia-256-cfb,
 - chacha20-ietf-poly1305, xchacha20-ietf-poly1305,
 - salsa20, chacha20, chacha20-ietf.

```
    wrt_ss_socks_addr: 127.0.0.1
    wrt_ss_socks_port: 11080
```
Set listening interface/port for incoming SOCKS proxy requests.
Use address `0.0.0.0` to listen on all available interfaces.

    wrt_ss_v2ray_upgrade: false
Allows to upgrade v2ray plugin binary.
By default the plugin is not upgraded if already installed.

    wrt_ss_v2ray_binary: /opt/usr/sbin/v2ray-plugin
The path to install v2ray plugin binary.


## Tags

- `wrt_ss_packages` -- install required packages
- `wrt_ss_v2ray` -- install v2ray plugin
- `wrt_ss_privoxy` -- setup http proxy support
- `wrt_ss_config` -- update configuration
- `wrt_ss_service` -- enables shadowsocks service
- `wrt_ss_all` -- all tasks


## Dependencies

None


## Example Playbook

    - hosts: keenetic
      roles:
         - role: ivansible.wrt_ss
           wrt_ss_host: myserver.com
           wrt_ss_socks_addr: 0.0.0.0


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
