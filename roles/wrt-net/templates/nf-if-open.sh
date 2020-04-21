{% extends "nf-if-script.sh" %}
{% block rules %}
    nf inet -I INPUT   -i "$device" -j ACCEPT
    nf inet -I OUTPUT  -o "$device" -j ACCEPT
    nf inet -I FORWARD -i "$device" -j ACCEPT
    nf inet -I FORWARD -o "$device" -j ACCEPT
{% endblock %}
