'''
rm /etc/apt/sources.list
'''
# Deb 12
'''
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://deb.debian.org/debian bookworm-backports main contrib non-free
EOF
'''
# Deb 11
'''
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF
'''
# Deb 10
'''
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian Buster main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian Buster-updates main contrib non-free
deb http://deb.debian.org/debian Buster-backports main contrib non-free
EOF
'''
# Deb 12 + proxmox
'''
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://deb.debian.org/debian bookworm-backports main contrib non-free
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg 
'''
# Deb 11 + proxmox
'''
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF
wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg 
'''
# Deb 10 + proxmox
'''
cat >  /etc/apt/sources.list  << EOF
deb http://deb.debian.org/debian Buster main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian Buster-updates main contrib non-free
deb http://deb.debian.org/debian Buster-backports main contrib non-free
deb http://download.proxmox.com/debian/pve buster pve-no-subscription
EOF
wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg 
'''
'''
apt update && apt-get dist-upgrade -y && apt install proxmox-ve postfix open-iscsi ifupdown2 -y && apt remove os-prober -y && apt autoremove -y
'''