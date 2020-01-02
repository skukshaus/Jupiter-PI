#! /bin/sh
### BEGIN INIT INFO
#
#
# .--.     .      .--.
# |   )   _|_     |   )
# |--: .  .|  .-. |--:  .-. .-.
# |   )|  || (.-' |   )(.-'(.-'
# '--' `--|`-'`--''--'  `--'`--'
#         ;
#      `-'
#
# Provides:          
# Short-Description: ShallaList
# Description:       Holt sich die aktuelle Shallalist Blacklist
### END INIT INFO


log() {
	echo "$(date '+%b %d %H:%M:%S') $(hostname) shalla: $1"
	echo "$(date '+%b %d %H:%M:%S') $(hostname) shalla: $1" >> /etc/squidguard/shalla.log
}

cd /tmp
log 'Lade Blacklist runter...'
wget -q http://www.shallalist.de/Downloads/shallalist.tar.gz
log 'Extrahiere Daten...'
tar -xzf shallalist.tar.gz -C /var/lib/squidguard/db
chown -R proxy:proxy /var/lib/squidguard/db
log 'Erstelle Datenbanken...'
squidGuard -C all
chown -R proxy:proxy /var/lib/squidguard/db
log 'Datenbanken wurden erstellt...'
rm -rf /tmp/shallalist.tar.gz

exit 0