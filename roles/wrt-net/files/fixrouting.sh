#!/opt/bin/bash
#set -x

interval=60
timeout=1
prefix_iface=ISP
metric=256
lo_iface=lo
lo_ipv4=""
lo_ipv6=""

. /opt/etc/net/config

PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

declare -A selections

detect_prefix()
{
    ndmq -x -p 'show ipv6 prefix' |
        xml sel -t -m "/response/prefix[interface='$prefix_iface']" -v prefix |
        sed -r 's!:*(/[0-9]*)?$!!' |
        head -1
}

set_static_routes()
{
    prefix=$(detect_prefix)

    while read via dst_list comment; do
        via="${via/^/$prefix}"
        [[ $dst_list =~ : ]] && proto='-6' || proto='-4'

        for dst in ${dst_list//,/ } ; do
            dst="${dst/^/$prefix}"
            ip "$proto" route replace "$dst" via "$via" metric "$metric"
        done
    done < /opt/etc/net/routes
}

update_dynamic_routes()
{
    prefix=$(detect_prefix)

    while read via_list dst_list comment; do
        [[ $dst_list =~ : ]] && proto='-6' || proto='-4'

        via=""
        for try in ${via_list//,/ } ; do
            try="${try/^/$prefix}"
            if ping "$proto" -c1 -w "$timeout" -W "$timeout" "$try" &>/dev/null ; then
                via="$try"
                break
            fi
        done

        if [ -z "$via" ] || [ "${selections[$via_list]}" = "$via" ]; then
            continue
        fi
        selections["$via_list"]="$via"
        logger -t net "net: ipv6 route '${comment//_/ }' via ${via}"

        for dst in ${dst_list//,/ } ; do
            dst="${dst/^/$prefix}"
            ip "$proto" route replace "$dst" via "$via" metric "$metric"
        done
    done < /opt/etc/net/spidr
}

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

run_netfilter_hooks()
{
    for hook in /opt/etc/ndm/netfilter.d/*.* ; do
        "$hook" -f
    done
}

set_loopback_addr()
{
    [ -n "$lo_iface" ] && [ -n "$lo_ipv4" ] && ip -4 addr replace "$lo_ipv4" dev "$lo_iface"
    [ -n "$lo_iface" ] && [ -n "$lo_ipv6" ] && ip -6 addr replace "$lo_ipv6" dev "$lo_iface"
}

boot()
{
    set_loopback_addr
    set_static_routes
    setup_netfilter_nat6
    run_netfilter_hooks
}

service()
{
    boot
    while true; do
        update_dynamic_routes
        sleep "$interval"
    done
}

case "$1" in
  boot)     boot    ;;
  service)  service ;;
  *)  echo "usage: $(basename "$0") boot|service" ;;
esac
