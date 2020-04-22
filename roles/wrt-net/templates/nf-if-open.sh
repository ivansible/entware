{% extends "nf-if-script.sh" %}
{% block rules %}
{% set put = wrt_net_netfilter_hooks_put_first |bool |ternary('-I','-A') %}
    nf inet {{ put }} INPUT   -i "$device" -j ACCEPT
    nf inet {{ put }} OUTPUT  -o "$device" -j ACCEPT
    nf inet {{ put }} FORWARD -i "$device" -j ACCEPT
    nf inet {{ put }} FORWARD -o "$device" -j ACCEPT
{% endblock %}
