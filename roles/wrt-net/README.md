# ivansible.wrt_net

[![Github Test Status](https://github.com/ivansible/wrt-net/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/wrt-net/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/wrt-net.svg?branch=master)](https://travis-ci.org/ivansible/wrt-net)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.wrt__net-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/wrt_net/)

This role configures dynamic routing on keenetic entware.


## Requirements

None


## Variables

    wrt_net_ifs_open: []
List of interface names to be open in netfilter for input and forward.

    wrt_net_ifs_nat6: []
List of network interfaces to setup IPv6 NAT from local prefix.

    wrt_net_prefix_dev: br0
    wrt_net_prefix_len: 64
These settings affect the IPv6 prefix detector (based on the iproute2 `ip` command).
The `dev` setting limits prefixes to those with given network device.
The `len` setting limits prefixes to those with given prefix length.
Out of remaining prefixes, the first one will be used.


## Tags

- `wrt_net_packages` -- install routing packages
- `wrt_net_routing` -- update static/dynamic routes
- `wrt_net_hooks` -- create netfilter hooks
- `wrt_net_firewall` -- amend firewall rules
- `wrt_net_all` -- all tasks


## Dependencies

None


## Example Playbook

    - hosts: entware
      roles:
         - role: ivansible.wrt_net
           var: val


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
