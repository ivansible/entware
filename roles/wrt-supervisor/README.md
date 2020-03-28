# ivansible.wrt_supervisor

[![Github Test Status](https://github.com/ivansible/wrt-supervisor/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/wrt-supervisor/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/wrt-supervisor.svg?branch=master)](https://travis-ci.org/ivansible/wrt-supervisor)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.wrt__supervisor-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/wrt_supervisor/)

This role installs [supervisor](http://supervisord.org/) service manager
on Keenetic routers.


## Requirements

None


## Variables

    wrt_use_supervisor: false
Enables installation of supervisor. Role is skipped if this is false.
This flag is also indirectly used by other _wrt_ roles.
You may want to disable supervisor since it's memory hungry.

    wrt_supervisor_port: 9001
Supervisor will listen for control commands on this localhost port.


## Tags

- `wrt_supervisor_all` -- all tasks


## Dependencies

None


## Example Playbook

    - hosts: keenetic
      roles:
         - role: ivansible.wrt_supervisor
           wrt_use_supervisor: true


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
