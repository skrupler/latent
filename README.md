# latent.sh
`latent.sh` is a autostart script written in bash for openvpn, rtorrent and sysvinit/systemd. It ables you to with little hassle
create a separate networked namespace (copy of the network stack) and connect it over openvpn isolating it from the rest of
the system. It then launches rtorrent into a byobu session and binds it (-b <ipaddr>) to the ip address.

# Visualization
```bash
        +------+       +-------+       +-------+       +-------+      +---------+      +----------+
        | eth0 |-------| veth0 |-------| veth1 |-------| netns |------| openvpn |------| rtorrent |
        +------+       +-------+       +-------+       +-------+      +---------+      +----------+
```

# Requirements
The script depends on these packages.

* byobu
* openvpn
* rtorrent

# How it works
The gist of it is that a netns is created upon runtime and iptables are configured accordingly via virtual eth's or (veths for short) making the netns able to access the network.
Then a openvpn connection is established and the rtorrent instance is binded to the ipaddress acquired by openvpn.

# Boot managers
It works with a varity of boot managers. 

## Upstart
todo

## SysVinit
todo

## Systemd
Systemd works perfect since you can just simply create a systemd unit and call the script with the `start` and `stop` parameters.




