#!/bin/sh
#set -x

peer="$1"
config="/opt/etc/sshtun/${peer}"
if [ -z "$peer" ] || [ ! -r "$config" ]; then
    echo "usage: $(basename "$0") PEER"
    exit 1
fi

ip4gw=10.1.1
ip6gw=fd00:1
device=tun1

# shellcheck disable=SC1090
. "$config"

ip4local="${ip4gw}.2"
ip4peer="${ip4gw}.1"
ip6local="${ip6gw}::2"
ip6peer="${ip6gw}::1"

/opt/sbin/ip link set dev "$device" up
/opt/sbin/ip -4 addr flush dev "$device"
/opt/sbin/ip -6 addr flush dev "$device"
/opt/sbin/ip -4 addr add "$ip4local/30"  peer "$ip4peer" dev "$device"
/opt/sbin/ip -6 addr add "$ip6local/126" peer "$ip6peer" dev "$device"

/opt/etc/ndm/netfilter.d/${device}.open -f
