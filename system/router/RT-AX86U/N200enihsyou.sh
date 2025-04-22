#!/bin/sh
# please link me, I will run when nat-start event occur.
# ln -s /jffs/.koolshare/enihsyou/N200enihsyou.sh /jffs/.koolshare/init.d/

alias logme='logger "[enihsyou]:"'

# make router responed to IPv6 ARP query
if [ ! -e /jffs/configs/dnsmasq.conf.add ]; then
  logme "create /jffs/configs/dnsmasq.conf.add"
  ipv6_hostname="$(nvram get lan_hostname)" # RT-AX86U-CE58
  ipv6_hostname="$ipv6_hostname-IPv6"       # RT-AX86U-CE58-IPv6
  echo "interface-name=$ipv6_hostname,br0/6" >> /jffs/configs/dnsmasq.conf.add
  service restart_dnsmasq
fi

# link avahi-daemon.postconf
if [ ! -e /jffs/scripts/avahi-daemon.postconf ]; then
  if [ -f /jffs/.koolshare/enihsyou/avahi-daemon.postconf ]; then
    logme "link /jffs/scripts/avahi-daemon.postconf"
    ln -sf /jffs/.koolshare/enihsyou/avahi-daemon.postconf /jffs/scripts/avahi-daemon.postconf
  else
    logme "avahi-daemon.postconf not found, please check"
  fi
fi

# append homebridge-miio iptables rules
if ! iptables -t nat -C POSTROUTING -o br0 -p udp --dport 54321 -s 192.168.1.0/24 -j MASQUERADE > /dev/null 2>&1; then
  logme "append homebridge-miio iptables rules"
  iptables -t nat -A POSTROUTING -o br0 -p udp --dport 54321 -s 192.168.1.0/24 -j MASQUERADE
fi
