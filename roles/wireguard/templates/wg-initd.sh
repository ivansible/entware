#!/bin/sh
#
# Startup script for wireguard
#
#set -x

{% if wrt_wg_prefer_userspace |bool %}
export WG_QUICK_PREFER_USERSPACE=true
{% endif %}
PATH=/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

start()
{
{% for dev in devs %}
    wg-quick up {{ dev.0 }}
{% endfor %}
}

stop()
{
{% for dev in devs %}
    wg-quick down {{ dev.0 }}
{% endfor %}
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
