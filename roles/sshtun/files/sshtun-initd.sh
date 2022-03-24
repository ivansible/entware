#!/bin/sh
#set -x

# Note: PROCS is pattern, PREARGS is script
ENABLED=yes
PROCS=sshtun-
ARGS=""
PREARGS=/opt/usr/sbin/sshtun-service.sh
DESC="sshtun client"
PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Hack rc.func into full-string search
pidof()
{
    echo `pgrep -f $1`
}

killall()
{
    sig=-TERM
    case "$1" in
        -*)  sig=$1
             shift
             ;;
    esac
    pids=`pgrep -f $1`
    [ -n "$pids" ] && kill $sig $pids
}

. /opt/etc/init.d/rc.func
