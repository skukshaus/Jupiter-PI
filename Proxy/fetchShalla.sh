#! /bin/sh
### BEGIN INIT INFO
# Provides:          
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Holt sich die aktuelle Shallalist Blacklist
# Description:       Holt sich die aktuelle Shallalist Blacklist
### END INIT INFO

echo "+-------------------------------------------------------------------+"
echo "|                  ______      _                                    |"
echo "|                 (_____ \    (_)                                   |"
echo "|                  _____) )___ _ _   _ _   _ _   _                  |"
echo "|                 |  ____/ ___) | | | | | | ( \ / )                 |"
echo "|                 | |   | |   | |\ V /| |_| |) X (                  |"
echo "|                 |_|   |_|   |_| \_/  \____(_/ \_)                 |"
echo "|                                                                   |"
echo "+-------------------------------------------------------------------+"

log() {
	echo "$(date '+%b %d %H:%M:%S') $(hostname) shalla: $1"
	echo "$(date '+%b %d %H:%M:%S') $(hostname) shalla: $1" >> /etc/squidguard/shalla.log
}

cd /tmp
log 'Lade Blacklist runter...'
wget http://www.shallalist.de/Downloads/shallalist.tar.gz
log 'Extrahiere Daten...'
tar -xzf shallalist.tar.gz -C /var/lib/squidguard/db
chown -R proxy:proxy /var/lib/squidguard/db
log 'Erstelle Datenbanken...'
squidGuard -C all
chown -R proxy:proxy /var/lib/squidguard/db
log 'Datenbanken wurden erstellt...'
rm -rf /tmp/shallalist.tar.gz

exit 0