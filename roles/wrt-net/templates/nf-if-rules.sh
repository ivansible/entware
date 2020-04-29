{% extends "nf-if-script.sh" %}
{% block init %}
DEVICE={{ device }}
{% endblock %}
{% block case %}
  filter|force)  rules ;;
{% endblock %}
{% block rules %}
rules()
{
{% if indirect %}
    nf -q {{ domain }} -N {{ n_chain }}
{% endif %}
{% if direct and std_rules %}
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
{%   set src_ipset = r.src_ipset |default('') %}
{%   set src_ipset_c = ' -m set --match-set %s src' % src_ipset if src_ipset else '' %}
{%   set proto_s = r.proto |default('inet',true) %}
{%   set sport = r.sport |default(0) |int %}
{%   set sport_c = ' --sport %d' % sport if sport else '' %}
{%   set port_val = r.dport |default(r.port) |default('') %}
{%   set port_str = port_val |string
                    if port_val is string or port_val is integer
                    else port_val |flatten |join(',') %}
{%   for port_tok in port_str.strip().split(',') %}
{%     set port_s = port_tok.strip() %}
{%     set dport = port_s.split('/').0 if '/' in port_s else port_s %}
{%     set dport_c = ' --dport %s' % dport.replace('-',':') if dport else '' %}
{%     set cond = src_c + dst_c + sport_c + dport_c + src_ipset_c %}
{%     set proto = port_s.split('/').1 if '/' in port_s else proto_s %}
{%     set r_domain = r.domain |default(domain, true) %}
{%     if (domain == r_domain or 'inet' in [domain, r_domain])
          and r_domain in ['ipv4', 'ipv6', 'inet']
          and domain in ['ipv4', 'ipv6', 'inet'] %}
{%       set c_domain = r_domain if domain == 'inet' else domain %}
{%       if proto in ['inet', 'any'] %}
    nf {{ c_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p tcp -m tcp{{ cond }} -j {{ verdict }}
    nf {{ c_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p udp -m udp{{ cond }} -j {{ verdict }}
{%       elif proto in ['tcp', 'udp'] %}
    nf {{ c_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p {{ proto }} -m {{ proto }}{{ cond }} -j {{ verdict }}
{%       else %}
{#       numeric protocol #}
    nf {{ c_domain }} {{ put }} {{ n_chain }}{{ device_c }} -p {{ proto }}{{ cond }} -j {{ verdict }}
{%       endif %}
{%     endif %}
{%   endfor %}
{% endfor %}
{% set put_chain = first |default(false) |bool |ternary('-I','-A') %}
{% if std_rules and indirect %}
    nf -q {{ domain }} -N {{ s_chain }}
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -m state --state RELATED,ESTABLISHED -j ACCEPT
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -m state --state INVALID -j DROP
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -p tcp -m tcp -m state --state NEW -j {{ n_chain }}
    nf {{ domain }} -A {{ s_chain }}{{ device_c }} -p udp -m udp -m state --state NEW -j {{ n_chain }}
{% endif %}
{% if std_rules and got_ipv4 %}
    nf ipv4 -A {{ s_chain }}{{ device_c }} -p icmp -j ACCEPT
{% endif %}
{% if std_rules and got_ipv6 %}
{%   for icmp6_type in [133, 134, 135, 136] %}
    nf ipv6 -A {{ s_chain }}{{ device_c }} -p ipv6-icmp -m icmp6 --icmpv6-type {{ icmp6_type }} -j ACCEPT
{%   endfor %}
{% endif %}
{% if indirect and std_rules %}
    nf {{ domain }} {{ put_chain }} {{ f_chain }} -i {{ device }} -j {{ s_chain }}
{% endif %}
{% if indirect and not std_rules %}
    nf {{ domain }} {{ put_chain }} {{ f_chain }} -i {{ device }} -j {{ n_chain }}
{% endif %}
{% if std_lists and got_ipv4 %}
    nf ipv4 -I {{ f_chain }} -m state --state NEW -m set --match-set wrt-block-ipv4 src -i {{ device }} -j DROP
{% endif %}
{% if std_lists and got_ipv6 %}
    nf ipv6 -I {{ f_chain }} -m state --state NEW -m set --match-set wrt-block-ipv6 src -i {{ device }} -j DROP
{% endif %}
}
{% endblock %}
