#!/bin/sh
#
# Startup script for wireguard
#
#set -x

DEVICE={{ wrt_wg_dev }}
{% if wrt_wg_prefer_userspace |bool %}
export WG_QUICK_PREFER_USERSPACE=true
{% endif %}
PATH=/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

start()
{
    wg-quick up "$DEVICE"
}

stop()
{
    wg-quick down "$DEVICE"
}

check()
{
    wg show
}

case "$1" in
  start)   start ;;
  stop)    stop ;;
  restart) stop; start ;;
  check)   check ;;
  *)  echo "usage: $0 start|stop|restart|check" ;;
esac
