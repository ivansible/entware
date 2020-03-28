#!/bin/sh
#set -x

PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

prefix_iface=ISP

. /opt/etc/net/config

setup_netfilter_nat6()
{
    lsmod | grep -q ip6table_nat
    if [ $? != 0 ]; then
        moddir=/lib/modules/4.9-ndm-4
        insmod $moddir/nf_nat_ipv6.ko
        insmod $moddir/ip6table_nat.ko
        insmod $moddir/nf_nat_masquerade_ipv6.ko
        insmod $moddir/ip6t_MASQUERADE.ko
    fi
}

detect_prefix_full()
{
    ndmq -x -p 'show ipv6 prefix' |
        xml sel -t -m "/response/prefix[interface='$prefix_iface']" -v prefix |
        head -1
}

ip4rules()
{
    :
}

ip6rules()
{
    setup_netfilter_nat6
    prefix_cidr=$(detect_prefix_full)
    ip6tables -t nat -A POSTROUTING -s "$prefix_cidr" -o "$device" -j MASQUERADE
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
