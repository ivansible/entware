{% extends "nf-if-script.sh" %}
{% block init %}
DEVICE={{ device }}
{% endblock %}
{% block case %}
{%   if ichain in ['dnat'] %}
  nat|force)  rules ;;
{%   else %}
  filter|force)  rules ;;
{%   endif %}
{% endblock %}
{% block rules %}
rules()
{
{# ==== Standard Rules (Direct) ==== #}
{% if indirect %}
    nf -q {{ domain }} {{ tbl_c }}-N {{ n_chain }}
{% endif %}
{% if direct and std_rules %}
    nf {{ domain }} {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -m state --state RELATED,ESTABLISHED -j ACCEPT
    nf {{ domain }} {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -m state --state INVALID -j DROP
{% endif %}
{# ==== User Rules ==== #}
{% for r in rules if not (r.disable |default(false) |bool) %}
{%   set put = r.first |default(p_first) |bool |ternary('-I','-A') %}
{%   set r_dnat = r.dnat |d('') %}
{%   set dnat_verdict = 'DNAT --to-destination %s' % r_dnat if r_dnat else '' %}
{%   set filter_verdict = r.permit |default(false) |bool |ternary('ACCEPT', 'DROP') %}
{%   set verdict = dnat_verdict |default(filter_verdict, true) %}
{%   set src = r.src |default('') %}
{%   set dst = r.dst |default('') %}
{%   set src_c = ' -s %s' % src if src else '' %}
{%   set dst_c = ' -d %s' % dst if dst else '' %}
{%   set src_ipset = r.src_ipset |default('') %}
{%   set src_ipset_c = ' -m set --match-set %s src' % src_ipset if src_ipset else '' %}
{%   set proto_s = r.proto |default('inet',true) %}
{%   set sport = r.sport |default('',true) |regex_replace('/.*$','') |int %}
{%   set sport_c = ' --sport %d' % sport if sport else '' %}
{%   set port_val = r.dport |default(r.port) |default('') %}
{%   set port_str = [port_val] |flatten |join(',') %}
{%   for port_tok in port_str.strip().split(',') %}
{%     set port_s = port_tok.strip() %}
{%     set dport = port_s.split('/').0 if '/' in port_s else port_s %}
{%     set dport_c = ' --dport %s' % dport.replace('-',':') if dport else '' %}
{%     set cond = src_c + dst_c + sport_c + dport_c + src_ipset_c %}
{%     set proto = port_s.split('/').1 if '/' in port_s else proto_s %}
{%     set r_domain = r.domain |default(domain, true) %}
{%     if (domain == r_domain or 'inet' in [domain, r_domain])
          and r_domain in ['ipv4', 'ipv6', 'inet']
          and domain in ['ipv4', 'ipv6', 'inet']
          and port_s not in ['0', 'off', 'none', '-'] %}
{%       set c_domain = r_domain if domain == 'inet' else domain %}
{%       if proto in ['inet', 'any'] %}
    nf {{ c_domain }} {{ tbl_c }}{{ put }} {{ n_chain }}{{ device_c }} -p tcp -m tcp{{ cond }} -j {{ verdict }}
    nf {{ c_domain }} {{ tbl_c }}{{ put }} {{ n_chain }}{{ device_c }} -p udp -m udp{{ cond }} -j {{ verdict }}
{%       elif proto in ['tcp', 'udp'] %}
    nf {{ c_domain }} {{ tbl_c }}{{ put }} {{ n_chain }}{{ device_c }} -p {{ proto }} -m {{ proto }}{{ cond }} -j {{ verdict }}
{%       else %}
{#       numeric protocol #}
    nf {{ c_domain }} {{ tbl_c }}{{ put }} {{ n_chain }}{{ device_c }} -p {{ proto }}{{ cond }} -j {{ verdict }}
{%       endif %}
{%     endif %}
{%   endfor %}
{% endfor %}
{# ==== Standard Rules (Indirect) ==== #}
{% set put_chain = p_first |default(false) |bool |ternary('-I','-A') %}
{% if std_rules and indirect %}
    nf -q {{ domain }} {{ tbl_c }}-N {{ s_chain }}
    nf {{ domain }} {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -m state --state RELATED,ESTABLISHED -j ACCEPT
    nf {{ domain }} {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -m state --state INVALID -j DROP
    nf {{ domain }} {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -p tcp -m tcp -m state --state NEW -j {{ n_chain }}
    nf {{ domain }} {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -p udp -m udp -m state --state NEW -j {{ n_chain }}
{% endif %}
{% if std_rules and got_ipv4 %}
    nf ipv4 {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -p icmp -j ACCEPT
{% endif %}
{% if std_rules and got_ipv6 %}
{%   for icmp6_type in [133, 134, 135, 136] %}
    nf ipv6 {{ tbl_c }}-A {{ s_chain }}{{ device_c }} -p ipv6-icmp -m icmp6 --icmpv6-type {{ icmp6_type }} -j ACCEPT
{%   endfor %}
{% endif %}
{% if indirect and std_rules %}
    nf {{ domain }} {{ put_chain }} {{ f_chain }} -i {{ device }} -j {{ s_chain }}
{% endif %}
{% if indirect and not std_rules %}
    nf {{ domain }} {{ put_chain }} {{ f_chain }} -i {{ device }} -j {{ n_chain }}
{% endif %}
{# ==== Standard Lists ==== #}
{% set std_cond = '-i %s -m state --state NEW -m set --match-set' % device %}
{% if std_lists and got_ipv4 %}
{%   if wrt_net_int_ports %}
{%     for port_s in wrt_net_int_ports |reverse %}
{%       set dport = port_s.split('/').0 %}
{%       set proto = port_s.split('/').1 %}
    nf ipv4 {{ tbl_c }}-I {{ f_chain }} {{ std_cond }} wrt-int-ipv4 src -p {{ proto }} -m {{ proto }} --dport {{ dport }} -j ACCEPT
{%     endfor %}
{%   else %}
    nf ipv4 {{ tbl_c }}-I {{ f_chain }} {{ std_cond }} wrt-int-ipv4 src -j ACCEPT
{%   endif %}
    nf ipv4 {{ tbl_c }}-I {{ f_chain }} {{ std_cond }} wrt-block-ipv4 src -j DROP
{% endif %}
{% if std_lists and got_ipv6 %}
{%   if wrt_net_int_ports %}
{%     for port_s in wrt_net_int_ports |reverse %}
{%       set dport = port_s.split('/').0 %}
{%       set proto = port_s.split('/').1 %}
    nf ipv6 {{ tbl_c }}-I {{ f_chain }} {{ std_cond }} wrt-int-ipv6 src -p {{ proto }} -m {{ proto }} --dport {{ dport }} -j ACCEPT
{%     endfor %}
{%   else %}
    nf ipv6 {{ tbl_c }}-I {{ f_chain }} {{ std_cond }} wrt-int-ipv6 src -j ACCEPT
{%   endif %}
    nf ipv6 {{ tbl_c }}-I {{ f_chain }} {{ std_cond }} wrt-block-ipv6 src -j DROP
{% endif %}
{% if std_lists %}
    nf inet {{ tbl_c }}-I {{ f_chain }} -i lo -j ACCEPT
{% endif %}
}
{% endblock %}
