#!/bin/bash
### BEGIN INIT INFO
# Provides:          
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: 
# Description:       
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

rm -rf /etc/bind/named.conf.blocked
echo "Aktualisiere jetzt die Liste der Schädlingswebseiten"

wget -O /etc/bind/malmwaredomains -q "http://malwaredomains.lehigh.edu/files/justdomains"

while read entry
do 
	if [ -n "${entry}" ]
	then
		echo "zone \""$entry"\" {type master; file \"/etc/bind/db.empty\";};" >> /etc/bind/named.conf.blocked
	fi
done < /etc/bind/malmwaredomains
	
echo "DNS wird neugestartet (Das kann jetzt mitunter etwas dauern...)"
/etc/init.d/bind9 reload
echo "Du bist jetzt sicher!"