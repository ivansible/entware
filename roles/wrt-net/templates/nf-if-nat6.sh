{% extends "nf-if-script.sh" %}
{% block rules %}
{% set put = wrt_net_netfilter_hooks_put_first |bool |ternary('-I','-A') %}
    [ $nat6_recheck_module = 1 ] && setup_netfilter_nat6
    prefix_cidr=$(detect_prefix_full)
    nf ipv6 -t nat {{ put }} POSTROUTING -s "$prefix_cidr" -o "$device" -j MASQUERADE
{% endblock %}
{% block init %}
DEVICE=""

prefix_dev=br0
prefix_len=64
nat6_recheck_module=1
{# shellcheck disable=SC1091 #}
. /opt/etc/net/config
{% endblock %}
{% block utils %}

setup_netfilter_nat6()
{
    lsmod 2>/dev/null | grep -q ip6table_nat
{#  shellcheck disable=SC2181 #}
    if [ $? != 0 ]; then
        MOD_DIR=/lib/modules/4.9-ndm-4
        insmod $MOD_DIR/nf_nat_ipv6.ko
        insmod $MOD_DIR/ip6table_nat.ko
        insmod $MOD_DIR/nf_nat_masquerade_ipv6.ko
        insmod $MOD_DIR/ip6t_MASQUERADE.ko
    fi
}

detect_prefix_full()
{
    ip -o -6 route show |
        grep -Ev '^ff00|^fe80' |
        grep "dev ${prefix_dev}" |
        awk '{print $1}' |
        grep ":/${prefix_len}" |
        head -1
}
{% endblock %}
{% block case %}
  nat|force)  rules ;;
{% endblock %}
