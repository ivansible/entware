#!/opt/bin/bash
#set -x

interval=60
timeout=1
prefix_dev=br0
prefix_len=64
metric=256
lo_dev=lo
lo_ipv4=""
lo_ipv6=""

. /opt/etc/net/config

PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin

declare -A selections

detect_prefix_full()
{
    ip -o -6 route show |
        grep -Ev '^ff00|^fe80' |
        grep "dev ${prefix_dev}" |
        awk '{print $1}' |
        grep ":/${prefix_len}" |
        head -1
}

detect_prefix()
{
    detect_prefix_full | sed -r 's!:*(/[0-9]*)?$!!'
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
    done < /opt/etc/net/static-routes
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
        logger -t net "route '${comment//_/ }' via ${via}"

        for dst in ${dst_list//,/ } ; do
            dst="${dst/^/$prefix}"
            ip "$proto" route replace "$dst" via "$via" metric "$metric"
        done
    done < /opt/etc/net/dynamic-routes
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

create_ipsets()
{
    ipset create -exist wrt-int-ipv4 hash:net family inet  comment
    ipset create -exist wrt-int-ipv6 hash:net family inet6 comment

    for int_hosts in /opt/etc/net/int-hosts* ; do
      while read ip comment; do
        [[ $ip =~ : ]] && list=wrt-int-ipv6 || list=wrt-int-ipv4
        ipset add -exist "$list" "$ip" comment "${comment//_/ }"
      done < "$int_hosts"
    done

    ipset create -exist wrt-block-ipv4 hash:net family inet  timeout 0 comment
    ipset create -exist wrt-block-ipv6 hash:net family inet6 timeout 0 comment
    while read ip comment; do
        [[ $ip =~ : ]] && list=wrt-block-ipv6 || list=wrt-block-ipv4
        ipset add -exist "$list" "$ip" comment "${comment//_/ }"
    done < /opt/etc/net/block-hosts
}

run_netfilter_hooks()
{
    for hook in /opt/etc/ndm/netfilter.d/*.* ; do
        "$hook" -f
    done
}

set_loopback_addr()
{
    [ -n "$lo_dev" ] && [ -n "$lo_ipv4" ] && ip -4 addr replace "$lo_ipv4" dev "$lo_dev"
    [ -n "$lo_dev" ] && [ -n "$lo_ipv6" ] && ip -6 addr replace "$lo_ipv6" dev "$lo_dev"
}

boot()
{
    set_loopback_addr
    set_static_routes
    setup_netfilter_nat6
    create_ipsets
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
