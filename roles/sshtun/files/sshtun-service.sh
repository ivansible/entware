#!/bin/sh
#set -x

. /opt/etc/sshtun/config

while true; do
  /opt/bin/logger -t sshtun "sshtun: restart ${host_alias}"
  ssh sshtun-${ssh_alias}
  sleep $interval
done
