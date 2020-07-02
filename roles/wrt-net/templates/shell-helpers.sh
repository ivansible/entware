nfstat()
{
    local log="{{ wrt_net_nf_log }}"
    local mon=${1:-$(date '+%m')}
    local from=${2:-1}
    local to=${3:-30}
    local day mmdd cnt
    for day in $(seq "$from" "$to"); do
        mmdd=$(printf '%02d-%02d' "$mon" "$day")
        cnt=$(sort "$log" |grep -c "$mmdd")
        echo "$day $cnt"
    done
}
