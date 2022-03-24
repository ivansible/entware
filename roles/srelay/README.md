# ivansible.wrt_srelay

[![Github Test Status](https://github.com/ivansible/wrt-srelay/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/wrt-srelay/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/wrt-srelay.svg?branch=master)](https://travis-ci.org/ivansible/wrt-srelay)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.wrt__srelay-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/wrt_srelay/)

This role installs [srelay](https://github.com/gco/srelay/#readme)
socks proxy on Keenetic routers.


## Requirements

None


## Variables

    wrt_srelay_enable: false
Enables installation of socks server. Role is skipped if this is false.

    wrt_srelay_port: 1080
Listening port of socks server.

    wrt_srelay_addr: ~
If non-empty, the socks server will be restricted to listening on the given
IP address. Otherwise, the server will listen on all interfaces (the default).


## Tags

- `wrt_srelay_all` -- all tasks


## Dependencies

None


## Example Playbook

    - hosts: keenetic
      roles:
         - role: ivansible.wrt_srelay
           wrt_srelay_enable: true
           wrt_srelay_addr: 127.0.0.1
           wrt_srelay_port: 11080


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
