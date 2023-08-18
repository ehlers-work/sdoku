```
rm /etc/apt/sources.list
````

# Deb 12

````
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://deb.debian.org/debian bookworm-backports main contrib non-free
EOF
````

# Deb 11

````
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF
````

# Deb 10

````
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian Buster main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian Buster-updates main contrib non-free
deb http://deb.debian.org/debian Buster-backports main contrib non-free
EOF
````

# Deb 12 + proxmox

````
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://deb.debian.org/debian bookworm-backports main contrib non-free
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
````

# Deb 11 + proxmox + OneNebula

````
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
deb https://downloads.opennebula.io/repo/6.6/Debian/11 stable opennebula
EOF
wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
````

# Deb 10 + proxmox + OneNebula

````
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian Buster main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian Buster-updates main contrib non-free
deb http://deb.debian.org/debian Buster-backports main contrib non-free
deb http://download.proxmox.com/debian/pve buster pve-no-subscription
deb https://downloads.opennebula.io/repo/6.6/Debian/10 stable opennebula
EOF
wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg
wget -q -O- https://downloads.opennebula.io/repo/repo2.key | apt-key add -
````

````

apt update && apt-get dist-upgrade -y 
apt install -y snapd gnupg wget apt-transport-https && snap install core core18 core20 core22 docker
source ~/.bashrc
usermod -a -G docker oneadmin

rm /etc/hostname
cat >  /etc/hostname  << EOF
# HOSTNAME
4c3s
EOF

rm /etc/cloud/templates/hosts.debian.tmpl
cat >  /etc/cloud/templates/hosts.debian.tmpl  << EOF
# hosts.templ
## template:swebz.it
{#
This file (/etc/cloud/templates/hosts.debian.tmpl) is only utilized
if enabled in cloud-config.  Specifically, in order to enable it
you need to add the following to config:
   manage_etc_hosts: True
-#}
# Your system has configured 'manage_etc_hosts' as True.
# As a result, if you wish for changes to this file to persist
# then you will need to either
# a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl
# b.) change or remove the value of 'manage_etc_hosts' in
#     /etc/cloud/cloud.cfg or cloud-config from user-data
#
{# The value '{{hostname}}' will be replaced with the local-hostname -#}
# 127.0.1.1 {{fqdn}} {{hostname}}
127.0.0.1 localhost {{hostname}}
212.227.225.148 {{hostname}}.swebz.it {{hostname}}

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

apt install opennebula opennebula-sunstone opennebula-fireedge opennebula-gate opennebula-flow opennebula-provision proxmox-ve postfix open-iscsi ifupdown2 -y && apt remove os-prober -y 
apt autoremove -y
````
