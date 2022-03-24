#!/bin/sh

ENABLED=yes
PROCS=yggdrasil
ARGS="-useconffile /opt/etc/yggdrasil/yggdrasil.conf"
PREARGS=""
DESC=$PROCS
PATH=/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

. /opt/etc/init.d/rc.func
