# latent.sh
`latent.sh` is a autostart script written in bash for `openvpn`, `rtorrent` and `sysvinit`/`systemd`. It ables you to with little hassle create a separate networked namespace (logical copy of the network stack) and connect it over openvpn isolating it from the rest of the system. It then launches rtorrent into a byobu session and binds it (-b <ipaddr>) to the ip address.

This is useful if you want to run certain processes like rtorrent in an isolated enviroment connected to the internet
via a vpn connection.

# How it works
The gist of it is that a `netns` is created upon runtime and `iptables` are configured accordingly via virtual eth's or (veths for short) making the `netns` able to access the network.
Then a `openvpn` connection is established and the `rtorrent` instance is binded to the ip address acquired by `openvpn`.

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

### 1) Clone the repo
```bash
$ git clone https://github.com/skrupler/latent.git .sh
```
### 2) Adjust the settings.
```bash
$ vim .sh/latent.sh
```

```bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
USER="HACKER1"
RTORRENT=/usr/bin/rtorrent
BYOBU=/usr/bin/byobu
BYOBU_NAME=secure
BYOBU_TITLE=rtorrent
IP=/sbin/ip
PIDFILE=/var/run/rtorrent.pid
SOCKET=/tmp/rpc.socket
IFACE="eth0"
NETNS="hidden"
VETH0="veth0"
VETH1="veth1"
DNS="nameserver 91.239.100.100"
OPVN=/etc/openvpn/openvpn.ovpn
SOCKET_NAME=rtmux
```

#### Tip
Do note that if you have a vpn provider with login credentials you can specify in your `.ovpn` configuration file a authentication directive `auth-user-pass /etc/openvpn/auth` which takes two lines, username and password on 2ndline.

### 3) Choose what boot manager you run and continue from there.

### Boot managers
It works with a varity of boot managers. 

#### Upstart/SysVinit
Put the `latent.sh` in `/etc/init.d/latent.sh` and activate it.

Register it with rc.d:
```bash
# update-rc.d latent.sh defaults 99
```

Make it executable:
```bash
# chmod 755 /etc/init.d/latent.sh
```

##### Usage:
```bash
# service latent.sh (start|stop|restart)
```

#### Systemd
Create a unit file in `/etc/systemd/system/latent.service`.

```bash
[Unit]
Description=latent.sh
After=network.target

[Service]
Type=forking
#Type=oneshot
#RemainAfterExit=yes
KillMode=none
ExecStart=/home/username/sh/latent.sh start
ExecStop=/home/username/sh/latent.sh stop
WorkingDirectory=%h
Restart=on-failure

[Install]
WantedBy=default.target
```

##### Usage:

```bash
systemctl enable latent.service
systemctl start|stop|restart latent.service
```
