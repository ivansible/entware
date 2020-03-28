#!/bin/sh
#set -x

PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

ip4rules()
{
    iptables -I INPUT   -i "$device" -j ACCEPT
    iptables -I OUTPUT  -o "$device" -j ACCEPT
    iptables -I FORWARD -i "$device" -j ACCEPT
    iptables -I FORWARD -o "$device" -j ACCEPT
}

ip6rules()
{
    ip6tables -I INPUT   -i "$device" -j ACCEPT
    ip6tables -I OUTPUT  -o "$device" -j ACCEPT
    ip6tables -I FORWARD -i "$device" -j ACCEPT
    ip6tables -I FORWARD -o "$device" -j ACCEPT
}

parse_args()
{
    device=""
    help=0
    while [ -n "$1" ]; do
        case "$1" in
          -f|--force)  table=force ;;
          -*)  help=1 ;;
          start|stop|check|restart) ;;
          *)  [ -z "$device" ] && device=$1 || help=1 ;;
        esac
        shift
    done

    if [ -z "$device" ]; then
        link=$(basename "$0")
        case "$link" in
          *.*)  device=${link%%.*} ;;
        esac
    fi

    if [ $help = 1 ] || [ -z "$device" ]; then
        prog=$(readlink -f "$0")
        echo "usage: $(basename "$prog") [-f] device"
        exit 1
    fi
}


parse_args "$@"

case "$table" in
  filter)
    # shellcheck disable=SC2154
    case "$type" in
      iptables)   ip4rules ;;
      ip6tables)  ip6rules ;;
    esac
    ;;
  force|every)
    ip4rules
    ip6rules
    ;;
esac

exit 0
