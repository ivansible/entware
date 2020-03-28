#!/bin/sh
# Activate swap on every boot
#
#set -x

SWAP_SIZE_MB={{ wrt_swap_size_mb |int }}
SWAP_FILE={{ wrt_swap_file }}
PATH=/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin

prepare()
{
  echo "prepare swap file..."
  dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$SWAP_SIZE_MB
  chmod 600 "$SWAP_FILE"
  mkswap "$SWAP_FILE"
}

case "$1" in
  start|restart)
    if [ "$SWAP_SIZE_MB" -gt 0 ]; then
      test -f "$SWAP_FILE" || prepare
      swapon "$SWAP_FILE"
      tail -n+2 /proc/swaps
    fi
    ;;
  stop)
    if grep -q "$SWAP_FILE" /proc/swaps ; then
      swapoff "$SWAP_FILE"
    fi
    tail -n+2 /proc/swaps
    ;;
  check)
    cat /proc/swaps
    ;;
  *)
    echo "usage: $0 start|restart|stop|check"
    ;;
esac
