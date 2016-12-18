# latent.sh
`latent.sh` is a autostart script written in bash for openvpn, rtorrent and sysvinit/systemd. It ables you to with little hassle
create a separate networked namespace (logical copy of the network stack) and connect it over openvpn isolating it from the rest of the system. It then launches rtorrent into a byobu session and binds it (-b <ipaddr>) to the ip address.

This is useful if you want to run certain processes like rtorrent in an isolated enviroment connected to the internet
via a vpn connection.

# How it works
The gist of it is that a netns is created upon runtime and iptables are configured accordingly via virtual eth's or (veths for short) making the netns able to access the network.
Then a openvpn connection is established and the rtorrent instance is binded to the ipaddress acquired by openvpn.

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

.. and obviously a vpn provider you either run yourself or trust enough with your illicit traffic ;-)

# Installation
I didn't think this thru.

### 1)
Clone the repo.
```bash
$ git clone https://github.com/skrupler/latent.git .sh
```
### 2)
Adjust the settings.
```bash
$ vim latent.sh
```

### 3)



Copy the `latent.sh` script and put it where ever you like it. Adjust the settings to your
liking. Also dont forget to edit add the `


## Boot managers
It works with a varity of boot managers. 

### Upstart
todo

### SysVinit
todo

### Systemd
Systemd works perfect since you can just simply create a systemd unit and call the script with the `start` and `stop` parameters.




