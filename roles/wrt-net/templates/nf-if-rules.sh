{% extends "nf-if-script.sh" %}
{% block init %}
DEVICE={{ device }}
{% endblock %}
{% block rules %}
{% if not direct %}
    nf -q {{ domain }} -N {{ n_chain }}
{% endif %}
{% if direct and apply_std_rules %}
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -m state --state RELATED,ESTABLISHED -j ACCEPT
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -m state --state INVALID -j DROP
{% endif %}
{% for r in rules %}
{%   set put = r.first |default(false) |bool |ternary('-I','-A') %}
{%   set verdict = r.permit |default(false) |bool |ternary('ACCEPT', 'DROP') %}
{%   set src = r.src |default('') %}
{%   set dst = r.dst |default('') %}
{%   set src_c = ' -s %s' % src if src else '' %}
{%   set dst_c = ' -d %s' % dst if dst else '' %}
{%   set proto_s = r.proto |default('inet',true) %}
{%   set port_val = r.port |default('') %}
{%   set port_str = port_val |string
                    if port_val is string or port_val is integer
                    else port_val |flatten |join(',') %}
{%   for port_tok in port_str.strip().split(',') %}
{%     set port_s = port_tok.strip() %}
{%     set dport = port_s.split('/').0 if '/' in port_s else port_s %}
{%     set dport_c = ' --dport %s' % dport.replace('-',':') if dport else '' %}
{%     set cond = src_c + dst_c + dport_c %}
{%     set proto = port_s.split('/').1 if '/' in port_s else proto_s %}
{%     set r_domain = r.domain |default(domain, true) %}
{%     if (domain == r_domain or 'inet' in [domain, r_domain])
          and r_domain in ['ipv4', 'ipv6', 'inet'] %}
{%       if proto in ['inet', 'any'] %}
    nf {{ r_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p tcp -m tcp{{ cond }} -j {{ verdict }}
    nf {{ r_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p udp -m udp{{ cond }} -j {{ verdict }}
{%       elif proto in ['tcp', 'udp'] %}
    nf {{ r_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p {{ proto }} -m {{ proto }}{{ cond }} -j {{ verdict }}
{%       else %}
{#       numeric protocol #}
    nf {{ r_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p {{ proto }}{{ cond }} -j {{ verdict }}
{%       endif %}
{%     endif %}
{%   endfor %}
{% endfor %}
{% set put_chain = first |default(false) |bool |ternary('-I','-A') %}
{% if apply_std_rules %}
{%   if not direct %}
    nf -q {{ domain }} -N {{ s_chain }}
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -m state --state RELATED,ESTABLISHED -j ACCEPT
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -m state --state INVALID -j DROP
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -p tcp -m tcp -m state --state NEW -j {{ n_chain }}
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -p udp -m udp -m state --state NEW -j {{ n_chain }}
{%   endif %}
{%   if domain in ['inet', 'ipv4'] %}
    nf ipv4 -A {{ s_chain }}{{ device_c }} -p icmp -j ACCEPT
{%   endif %}
{%   if domain in ['inet', 'ipv6'] %}
{%     for icmp6_type in [133, 134, 135, 136] %}
    nf ipv6 -A {{ s_chain }}{{ device_c }} -p ipv6-icmp -m icmp6 --icmpv6-type {{ icmp6_type }} -j ACCEPT
{%     endfor %}
{%   endif %}
{%   if not direct %}
    nf {{ domain }} {{ put_chain }} INPUT -i {{ device }} -j {{ s_chain }}
{%   endif %}
{% elif not direct  %}
    nf {{ domain }} {{ put_chain }} INPUT -i {{ device }} -j {{ n_chain }}
{% endif %}
{% endblock %}
