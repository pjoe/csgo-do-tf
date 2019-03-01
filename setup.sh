#!/bin/bash
set -ex

# firewall
ufw allow 27015
ufw allow 27005/udp
ufw allow 27020/udp

cd /home/csgoserver
chown csgoserver:csgoserver serverfiles/csgo/cfg/*.cfg
su - csgoserver -c './csgoserver restart'

# cron
crontab -u csgoserver - <<"EOF"
#Server Name
*/5 * * * * /home/username/csgoserver monitor > /dev/null 2>&1
*/30 * * * * /home/username/csgoserver update > /dev/null 2>&1
00 6 * * *  /home/username/csgoserver force-update > /dev/null 2>&1
0 0 * * 0 /home/username/csgoserver update-functions > /dev/null 2>&1
EOF
