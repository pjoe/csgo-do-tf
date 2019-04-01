#!/bin/bash
set -ex

cd /home/csgoserver
chown csgoserver:csgoserver serverfiles/csgo/cfg/*.cfg

# metamod
if [ ! -e serverfiles/csgo/addons ]; then
    cd /home/csgoserver/serverfiles/csgo
    su csgoserver -c 'curl https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git969-linux.tar.gz | tar xvz'
    cd /home/csgoserver
fi

# sourcemod
if [ ! -e serverfiles/csgo/addons/sourcemod ]; then
    cd /home/csgoserver/serverfiles/csgo
    su csgoserver -c 'curl https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6276-linux.tar.gz | tar xvz'
    cd /home/csgoserver
fi
# remove defunct nextmap.smx
rm -f serverfiles/csgo/addons/sourcemod/plugins/nextmap.smx

# rankme
if [ ! -e serverfiles/csgo/addons/sourcemod/plugins/kento_rankme.smx ]; then
    cd /home/csgoserver/serverfiles/csgo/addons/sourcemod/plugins
    su csgoserver -c 'curl -OL https://github.com/rogeraabbccdd/Kento-Rankme/raw/master/plugins/kento_rankme.smx'
    cd /home/csgoserver
fi
if [ ! -e serverfiles/csgo/addons/sourcemod/translations/kento.rankme.phrases.txt ]; then
    cd /home/csgoserver/serverfiles/csgo/addons/sourcemod/translations
    su csgoserver -c 'curl -OL https://github.com/rogeraabbccdd/Kento-Rankme/raw/master/translations/kento.rankme.phrases.txt'
    cd /home/csgoserver
fi
# remove existing rankme db entry
sed -ie '/^\s*"rankme"/,/^\s*}/d' serverfiles/csgo/addons/sourcemod/configs/databases.cfg
# remove ending }
sed -i 's/^}//' serverfiles/csgo/addons/sourcemod/configs/databases.cfg
cat >> serverfiles/csgo/addons/sourcemod/configs/databases.cfg <<"EOF"

    "rankme" 
    {        
        "driver"  "mysql"        
        "host"   "127.0.0.1"        
        "database"  "sourcemod"
        "user"   "root"        
        "pass"   "${mysql_password}"        
        //"timeout"   "0"
        "port"   "3306" 
    }
}
EOF
# rankme config
sed -i 's/\(rankme_mysql\).*$/\1 "1"/' serverfiles/csgo/cfg/sourcemod/kento.rankme.cfg
sed -i 's/\(rankme_rankbots\).*$/\1 "1"/' serverfiles/csgo/cfg/sourcemod/kento.rankme.cfg


su - csgoserver -c './csgoserver restart'

# cron
crontab -u csgoserver - <<"EOF"
#Server Name
*/5 * * * * /home/csgoserver/csgoserver monitor > /dev/null 2>&1
*/30 * * * * /home/csgoserver/csgoserver update > /dev/null 2>&1
00 6 * * *  /home/csgoserver/csgoserver force-update > /dev/null 2>&1
0 0 * * 0 /home/csgoserver/csgoserver update-functions > /dev/null 2>&1
EOF

# docker
docker-compose up -d