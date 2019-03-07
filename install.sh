#!/bin/bash
set -ex

# ufw
%{ for ip in split(" ", admin_ips) }
ufw insert 1 allow from ${ip}/32 to any port 22
%{ endfor }

# apt packages
dpkg --add-architecture i386
apt update
apt install -y \
    tmux \
    wget \
    ca-certificates \
    file \
    bsdmainutils \
    util-linux \
    python \
    bzip2 \
    gzip \
    unzip \
    binutils \
    bc \
    jq \
    lib32gcc1 \
    libstdc++6:i386\
    zlib1g:i386 \


if [ ! -e /home/csgoserver ]; then
    adduser --disabled-password --gecos "" csgoserver
fi

cd /home/csgoserver
if [ ! -e csgoserver ]; then
    su - csgoserver -c 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh csgoserver'
fi

if [ ! -e serverfiles/csgo ]; then
    su - csgoserver -c './csgoserver auto-install'
fi
