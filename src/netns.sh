#!/bin/bash   

# Settings
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
USER="WHOAMI"
IP=/sbin/ip
IFACE="eth0"
NETNS="hidden"
VETH0="veth0"
VETH1="veth1"
DNS="nameserver 91.239.100.100"
OPVN=/etc/openvpn/openvpn.ovpn
SOCKET_NAME=rtmux

remove_socket() {
    
    # Check if rpc socket exists and if it exists delete it.
    if [[ -e $SOCKET ]]; then
        rm -f $SOCKET
    fi
}

create_netns() {
    
    # Create namespace
    ip netns add ${NETNS}
    echo "Setting up ${NETNS}..."
    sleep 2
    
    # Bring loopback up
    ip netns exec ${NETNS} ip addr add 127.0.0.1/8 dev lo
    ip netns exec ${NETNS} ip link set lo up
    echo "Bringing up loopback device for ${NETNS}..."
    
    # Connect tubes from a to b
    ip link add ${VETH0} type veth peer name ${VETH1}
    ip link set ${VETH0} up
    ip link set ${VETH1} netns ${NETNS} up
    ip addr add 10.0.5.1/24 dev ${VETH0}
    echo "Connecting virtual circuits..."

    # Add default route
    ip netns exec ${NETNS} ip addr add 10.0.5.2/24 dev ${VETH1}
    ip netns exec ${NETNS} ip route add default via 10.0.5.1 dev ${VETH1}
    echo "Configuring default ip and route..."

    # Add DNS, can be changed in settings
    mkdir -p /etc/netns/${NETNS}
    touch /etc/netns/${NETNS}/resolv.conf # probably redundant 
    echo "$DNS" > /etc/netns/${NETNS}/resolv.conf
    echo "Setting up ${DNS}..."

    # IPTABLES
    iptables -A INPUT \! -i ${VETH0} -s 10.0.5.0/24 -j DROP
    iptables -t nat -A POSTROUTING -s 10.0.5.0/24 -o ${IFACE} -j MASQUERADE
	# if != 1 then;
    sysctl -q net.ipv4.ip_forward=1
    echo "Configuring iptables on ${IFACE}..."
    sleep 5
}

remove_netns() {
    
    # Removes network namespace    
    if [[ -e /etc/netns/${NETNS} ]]; then
        rm -f /etc/netns/${NETNS}
        iptables -D INPUT \! -i ${VETH0} -s 10.0.5.0/24 -j DROP
        iptables -t nat -D POSTROUTING -s 10.0.5.0/24 -o ${IFACE} -j MASQUERADE
        ip netns delete ${NETNS}
        sysctl -q net.ipv4.ip_forward=0
        echo "Restoring iptables on ${IFACE}..."
        sleep 3
    fi
}

get_public_ip(){

	extip=$(dig +short myip.opendns.com @resolver1.opendpn.com)
	printf 'Public IP: %s' "$extip"

}

conn_openvpn() {
    
    # You have to add 'daemon' to the end of *.opvn conf file to make it fork to background. 
    ip netns exec ${NETNS} openvpn --config "$OPVN"
    echo "Connection to VPN provider established."
	sleep 10
    
}

get_openvpn_ip() {
    
    # takes @params tun0,eth0
    VALIDIP=$(ip netns exec ${NETNS} ip addr ls "$1" | awk '/inet / {print $2}' | cut -d "/" -f1)
    echo "Connected IP: ${VALIDIP}"
    
}
