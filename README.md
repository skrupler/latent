# latent
Latent is a autostart script written in bash for openvpn, rtorrent and sysvinit/systemd. It ables you to with little hassle
create a separate networked namespace (copy of the network stack) and connect it over openvpn isolating it from the rest of
the system. It then launches rtorrent into a byobu session and binds it (-b <ipaddr>) to the ip address.

# This is to be considered a hack. PR's welcomed.

```bash
+------+       +-------+       +-------+       +-------+       +-------------+
| eth0 |---<---| VETH0 |---<---| VETH1 |---<---| netns |---<---| rtorrent -b |
+------+       +-------+       +-------+       +-------+       +-------------+
```

# Requirements

* byobu
* openvpn
* rtorrent

# How it works
The gist of it is that a netns is created upon runtime and iptables are configured accordingly via virtual eth's or (veths for short) making the netns able to access the network.
Then a openvpn connection is established 

# Boot managers
It works with a varity of boot managers. 

## Upstart
todo

## SysVinit
todo

## Systemd
Systemd works perfect since you can just simply create a systemd unit and call the script with the `start` and `stop` parameters.




