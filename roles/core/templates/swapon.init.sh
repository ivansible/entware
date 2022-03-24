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
  fallocate -l "${SWAP_SIZE_MB}M" "$SWAP_FILE"
  chmod 600 "$SWAP_FILE"
  mkswap "$SWAP_FILE"
}

case "$1" in
  start|restart)
    if [ -n "$SWAP_FILE" ] && [ -n "$SWAP_SIZE_MB" ] && [ "$SWAP_SIZE_MB" -gt 0 ]; then
      test -e "$SWAP_FILE" || prepare
      if ! grep -q "$SWAP_FILE" /proc/swaps ; then
        swapon "$SWAP_FILE"
      fi
      tail -n+2 /proc/swaps
    fi
    ;;
  stop)
    if [ -n "$SWAP_FILE" ] && grep -q "$SWAP_FILE" /proc/swaps ; then
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
