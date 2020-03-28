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


## Tags

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
