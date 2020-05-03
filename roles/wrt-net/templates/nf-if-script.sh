#!/bin/sh
#set -x
# ansible-managed

PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOG=/opt/var/log/netfilter.log
{% block init %}
DEVICE=""
{% endblock %}

{% block rules %}
rules()
{
}
{% endblock %}
{% block utils %}
{% endblock %}

nf()
{
    quiet=0
    if [ "$1" = '-q' ]; then
        quiet=1
        shift
    fi
    case "$1/$type" in
      ipv4/iptables|inet/iptables|ipv4/force)
        cmds="iptables" ;;
      ipv6/ip6tables|inet/ip6tables|ipv6/force)
        cmds="ip6tables" ;;
      inet/force)
        cmds="iptables ip6tables" ;;
      *)
        cmds="" ;;
    esac
    shift
    for cmd in $cmds; do
        for retry in 1 2 3; do
            [ $retry = 1 ] || sleep 1
            out=$("$cmd" -w "$@" 2>&1)
            ret=$?
            msg=""
            [ $ret = 0 ] && break
            [ $quiet = 1 ] && continue

            time=$(date '+%Y-%m-%d %H:%M:%S')
            case "$out" in
              *'Resource temporarily unavailable'* )
                err=EAGAIN
                ;;
              *'Invalid argument'* )
                err=EINVAL
                ;;
              *'No chain/target'* | *'No such file'* | *"Set "*"doesn't exist"* )
                err="\"$(echo "$out" |head -1)\""
                msg="[$time] FATAL: $table $prog ($ret) cmd: \"$cmd $*\" err: $err"
                echo "$msg" >> $LOG
                echo "$msg" 1>&2
                exit 1
                ;;
              *)
                err="\"$(echo "$out" |head -1)\""
                ;;
            esac
            msg="[$time] retry $table $prog ($ret) cmd: \"$cmd $*\" err: $err"
            echo "$msg" >> $LOG
        done
        [ -z "$msg" ] || echo "$msg" 1>&2
    done
}

parse_args()
{
    device=$DEVICE
    table=${table:--}
    type=${type:--}
    prog=$(basename "$0")
    help=0

    while [ -n "$1" ]; do
        case "$1" in
          -f|--force)  table=force; type=force ;;
          -*)  help=1 ;;
          start|stop|check|restart) ;;
          *)  [ -z "$device" ] && device=$1 || help=1 ;;
        esac
        shift
    done

    if [ -z "$device" ]; then
        case "$prog" in
          *.*)  device=${prog%%.*} ;;
        esac
    fi

    if [ $help = 1 ] || [ -z "$device" ]; then
        echo "usage: $prog [-f] device"
        exit 1
    fi
}

parse_args "$@"
case "$table" in
{% block case %}
  filter|force)  rules ;;
{% endblock %}
esac
exit 0
