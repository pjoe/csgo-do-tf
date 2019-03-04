#!/bin/bash
set -ex

# firewall
ufw allow 27015
ufw allow 27005/udp
ufw allow 27020/udp

cd /home/csgoserver
chown csgoserver:csgoserver serverfiles/csgo/cfg/*.cfg

# metamod
if [ ! -e serverfiles/csgo/addons ]; then
    cd /home/csgoserver/serverfiles/csgo
    su csgoserver -c 'curl https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git968-linux.tar.gz | tar xvz'
    cd /home/csgoserver
fi

# sourcemod
if [ ! -e serverfiles/csgo/addons/sourcemod ]; then
    cd /home/csgoserver/serverfiles/csgo
    su csgoserver -c 'curl https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6275-linux.tar.gz | tar xvz'
    cd /home/csgoserver
fi

# rankme
if [ ! -e serverfiles/csgo/addons/sourcemod/plugins/kento_rankme.smx ]; then
    cd /home/csgoserver/serverfiles/csgo/addons/sourcemod/plugins
    su csgoserver -c 'curl -OL https://github.com/rogeraabbccdd/Kento-Rankme/raw/master/plugins/kento_rankme.smx'
    cd /home/csgoserver
fi

su - csgoserver -c './csgoserver restart'

# cron
crontab -u csgoserver - <<"EOF"
#Server Name
*/5 * * * * /home/username/csgoserver monitor > /dev/null 2>&1
*/30 * * * * /home/username/csgoserver update > /dev/null 2>&1
00 6 * * *  /home/username/csgoserver force-update > /dev/null 2>&1
0 0 * * 0 /home/username/csgoserver update-functions > /dev/null 2>&1
EOF

# docker
docker-compose up -d