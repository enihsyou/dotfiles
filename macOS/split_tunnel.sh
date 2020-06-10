#! /usr/bin/env bash
# Author: Ryoka Kujo chunxiang.huang@mail.hypers.com
# Descripthon: Network tweaking script to make Internet access avaliable
#   while connection to Danone Pulse Secure VPN.

# network interface list can be retrieved by `networksetup -listallhardwareports`
# specify your network interface for internet access.
PUBLIC_INTERFACE=en7
# specify your network interface for VPN tunnel access.
TUNNEL_INTERFACE=utun2
# list ip/cidr addresses which needs route to intranet net.
TUNNEL_ROUTES=(10.200.11)
# list DNS servers used by public access.
PUBLIC_DNS=(10.0.8.97 10.0.0.1)

if [[ "$OSTYPE" != "darwin"* ]]; then
	echo "Script only supports macOS right now." 1>&2
	exit 1
fi

if (( EUID != 0 )); then
	echo "Please, run this command with sudo" 1>&2
	exit 1
fi

PUBLIC_GATEWAY=$(netstat -nrf inet | grep default | grep $PUBLIC_INTERFACE | awk '{print $2}')

echo "Resetting routes with gateway => $PUBLIC_GATEWAY"
echo
route -n delete default -ifscope $PUBLIC_INTERFACE
route -n delete -net default -interface $TUNNEL_INTERFACE
route -n add -net default "$PUBLIC_GATEWAY"

for subnet in "${TUNNEL_ROUTES[@]}"
do
	echo "Add static route $subnet to $TUNNEL_INTERFACE"
	echo
	route -n add -net "$subnet" -interface $TUNNEL_INTERFACE
done

echo "Set DNS for PulseSecure NIC."
# Reference. https://superuser.com/a/1482337 https://apple.stackexchange.com/a/324596
# we assume the default DNS set by pulsesecure are 10.200.0.132, 10.200.0.145
scutil <<- EOF
	get State:/Network/Service/net.pulsesecure.pulse.nc.main/DNS
	d.add ServerAddresses '*' ${PUBLIC_DNS[@]} 10.200.0.132 10.200.0.145
	set State:/Network/Service/net.pulsesecure.pulse.nc.main/DNS
EOF
