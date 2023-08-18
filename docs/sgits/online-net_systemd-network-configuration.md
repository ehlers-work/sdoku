# online.net: systemd Network Configuration with (r)DNS

## Introduction
This document will guide you through the process of setting up your online.net network addresses, DNS servers and rDNS records.
For IPv4 we will use **systemd-networkd** (part of [systemd](https://github.com/systemd/systemd)) and [**odhcp6c**](https://github.com/openwrt/odhcp6c) (OpenWrt embedded DHCPv6-client) together with **iproute2** for IPv6.
For DNS we'll use **systemd-resolved**.

systemd is the default init process on Arch Linux, Debian GNU/Linux, Fedora, Ubuntu and more. iproute2 is also preinstalled there. So, if you're using a distribution that uses systemd, this tutorial should work for you. If you're using Gentoo Linux first make sure that you're using systemd.

## Table of Contents
* [Introduction](#introduction)
* [Table of Contents](#table-of-contents)
* [IPv4](#ipv4)
* [IPv6](#ipv6)
    * [Installation](#installation)
      * [Arch Linux](#arch-linux)
      * [Debian GNU/Linux](#debian-gnulinux)
      * [Gentoo Linux](#gentoo-linux)
      * [Other Distribution](#other-distribution)
    * [Configuration](#configuration)
    * [systemd unit](#systemd-unit)
* [DNS](#dns)
    * [systemd-resolved configuration](#systemd-resolved-configuration)
    * [rDNSv4](#rdnsv4)
    * [rDNSv6](#rdnsv6)

## IPv4
First the easy part: IPv4 DHCP

Get the name of your public and private network device by comparing the IPv4 addresses with those in the webinterface:
```
$ ip a
```

For the following example I'll use `enp0s20f0` as the name for the public network device and `enp0s20f1` for my private network device.

Switch to your systemd-networkd `.network` files directory and list its contents:
```
$ cd /etc/systemd/network && ls
```

If you already have existing `.network` files in there, compare their contents with those of the files below and restart systemd-networkd (`sudo systemctl restart systemd-networkd`) if you changed something.
If you don't have an existing configuration, create 2 files with the following contents:
```
[Match]
Name=enp0s20f0

[Network]
DHCP=ipv4
```

```
[Match]
Name=enp0s20f1

[Network]
DHCP=yes
```

It's important that their names end with `.network`, otherwhise they'll be ignored by systemd-networkd.
Now start systemd-networkd and enable it to run on startup:
```
$ sudo systemctl enable --now systemd-networkd
```

You can check the status with `sudo systemctl status systemd-networkd`.

The private network configuration for `enp0s20f1` above will also enable DHCPv6 for your private network. ~~But because systemd-networkd [doesn't yet support DHCPv6 prefix delegation](https://github.com/systemd/systemd/issues/1080) ([IA_PD](https://en.wikipedia.org/wiki/Prefix_delegation)) we need another DHCPv6 client for your public network.~~ As of version 237 systemd supports IA_PD, but apparently networkd isn't (yet) suitable for this usecase. And as `dhcpcd` and `dhclient` didn't seem to work permanently I tested `odhcp6c` and it runs perfectly.


If you used different tools for your network connection previously you can now stop and/or uninstall them (the online.net Arch Linux Image uses NetworkManager by default).

## IPv6
### Installation
#### Arch Linux
Install the [AUR package](https://aur.archlinux.org/packages/odhcp6c-git).

#### Debian GNU/Linux
Install the [experimental package](https://packages.debian.org/experimental/odhcp6c) from the repos.

#### Gentoo Linux
Install it from the [openwrt](https://gpo.zugaina.org/Overlays/openwrt/net-misc/odhcp6c) overlay.

#### Other Distribution
Install odhcp6c by cloning its [git repo](https://github.com/openwrt/odhcp6c) and compiling it.

First make sure you have all needed tools installed:
- make
- cmake
- git

Then cd to the directory where you want to clone odhcp6c to (e.g. your home directory) and proceed with the following commands:
```
$ git clone https://github.com/openwrt/odhcp6c
$ cd odhcp6c
$ cmake .
$ make
$ sudo make install
```

### Configuration
Start with looking up your IPv6 and your DUID in the webinterface.

Now add your IPv6 to the system:
```
$ sudo ip -6 a a <your address>/<your subnet size> dev <your public network device>
```

For example:
```
$ sudo ip -6 a a 2001:bc8:f34e::/48 dev enp0s20f0
```

Then log in as root (`sudo -i`) and start odhcp6c with the following command:
```
# odhcp6c -dP <your subnet size> -c <your duid> <your public network device>
```

For example:
```
# odhcp6c -dP 48 -c 10:f0:55:10:ae:87:45:19:05:97 enp0s20f0
```

Now your IPv6 should be set up and you should be able to use your public IPv6. You can easily test it by pinging a Google DNS Server with:
```
$ ping 2001:4860:4860::8888
```
**Note:** If you're using the default ping tool from gentoo you have to use `ping6` instead.

### systemd unit
For automatic configuration on boot you can create a systemd unit.
To do this create a file that ends with `.service` (`<your unit name>.service`, for example: `dhcpv6.service`) in the directory `/etc/systemd/system` with the following content:
```
[Unit]
Description=IPv6 Configuration with the OpenWrt embedded DHCPv6-client

[Service]
Type=simple
ExecStartPre=/usr/bin/ip -6 a a <your ipv6>/<your subnet size> dev <your public network device>
ExecStart=/usr/bin/odhcp6c -vP <your subnet size> -c <your duid> <your public network device>
ExecStopPost=/usr/bin/ip -6 a d <your ipv6>/<your subnet size> dev <your public network device>

[Install]
WantedBy=multi-user.target
```
I've added the option `-v` to `odhcp6c` in this file so that you have a log if something doesn't work. Also I removed `-d` cause in this case it's a subprocess of systemd anyways, so there's no need to daemonize it.

Now enable your unit with:
```
$ sudo systemctl enable <your unit name>.service
```

The next time you reboot your IPv6 will be automatically configured.

## DNS
### systemd-resolved configuration
The following steps are optional if you used an online.net install image. In this case your name resolution is already configured in `/etc/resolv.conf`, but you can still change it and use systemd-resolved instead.

Edit the configuration file `/etc/systemd/resolved.conf` and make sure it contains the following lines:
```
[Resolve]
DNS=2001:bc8:401::3 2001:bc8:1::16 62.210.16.6 62.210.16.7
FallbackDNS=2001:4860:4860::8888 2001:4860:4860::8844 8.8.8.8 8.8.4.4
Domains=online.net
```
The servers used in the example above are the online.net dedibox [DNS cache servers](https://documentation.online.net/en/dedicated-server/network/dedibox-network#dns_cache_servers) and the [Google DNS servers](https://developers.google.com/speed/public-dns/docs/using#google_public_dns_ip_addresses) as fallback.

Then start/restart the service with:
```
$ sudo systemctl restart systemd-resolved
```

Also don't forget to link the `/etc/resolv.conf` to the resolv.conf generated by systemd-resolved, which defines systemd-resolved as nameserver to send DNS requests to (this will overwrite your old resolv.conf):
```
$ sudo ln -srf /usr/lib/systemd/resolv.conf /etc/resolv.conf
```
**Note:** On Gentoo Linux the link target is `/lib/systemd/resolv.conf` since systemd-235.

### rDNSv4
You can set your rDNSv4 record in your webinterface.

### rDNSv6
Since it isn't possible to set reverse DNSv6 entries via the webinterface, you need to delegate your subnet to other nameservers, where you can set your PTR record. You can either set up two nameservers on your own or use a free dns service like [afraid.org](http://freedns.afraid.org/reverse/).

If you decide to use afraid.org, start by delegating your IPv6 Subnet to the afraid.org nameservers (ns{1,2,3,4}.afraid.org). After creating your account there, select `IPv6 Reverse` in the menu. Continue by adding your subnet and the IP address of your server afterwards.

And that's it, you're done! Your reverse should resolve after a few minutes.

If you have any questions feel free to write a comment. Feedback is also highly appreciated!