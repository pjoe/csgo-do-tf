#!/bin/bash
set -ex

# firewall
ufw allow 27015
ufw allow 27005/udp
ufw allow 27020/udp

cd /home/csgoserver
chown csgoserver:csgoserver serverfiles/csgo/cfg/*.cfg
su - csgoserver -c './csgoserver restart'