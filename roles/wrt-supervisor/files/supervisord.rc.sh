#!/bin/sh

ENABLED=yes
PROCS=supervisord
ARGS="-c /opt/etc/supervisord.conf -d /opt"
PREARGS=""
DESC=$PROCS
PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

. /opt/etc/init.d/rc.func