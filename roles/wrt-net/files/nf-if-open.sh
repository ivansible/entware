#!/bin/sh
#set -x

PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

ip4rules()
{
    iptables --wait --insert INPUT   -i "$device" --jump ACCEPT
    iptables --wait --insert OUTPUT  -o "$device" --jump ACCEPT
    iptables --wait --insert FORWARD -i "$device" --jump ACCEPT
    iptables --wait --insert FORWARD -o "$device" --jump ACCEPT
}

ip6rules()
{
    ip6tables --wait --insert INPUT   -i "$device" --jump ACCEPT
    ip6tables --wait --insert OUTPUT  -o "$device" --jump ACCEPT
    ip6tables --wait --insert FORWARD -i "$device" --jump ACCEPT
    ip6tables --wait --insert FORWARD -o "$device" --jump ACCEPT
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
