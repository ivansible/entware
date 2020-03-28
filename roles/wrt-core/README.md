# ivansible.wrt_entware

[![Github Test Status](https://github.com/ivansible/wrt-entware/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/wrt-entware/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/wrt-entware.svg?branch=master)](https://travis-ci.org/ivansible/wrt-entware)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.wrt__entware-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/wrt_entware/)

This role performs basic Entware setup on Keenetic routers:
  - install core packages;
  - configure ssh client and server;
  - add convenient shell aliases;
  - customize _tmux_ for user.


## Requirements

None


## Variables

    wrt_swap_size_mb: 0
Setup swap file of given size in megabytes, if not zero.

    wrt_ssh_authorized_keys: []
List of ssh key files to authorize with main user.


## Tags

- `wrt_core_packages` -- install core packages
- `wrt_core_ssh` -- configure ssh client and server
- `wrt_core_user` -- configure developer environment
- `wrt_core_all` -- all tasks


## Dependencies

None


## Example Playbook

    - hosts: keenetic
      roles:
        - ivansible.wrt_core


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
