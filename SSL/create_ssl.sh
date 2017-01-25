#!/bin/bash

echo "+-------------------------------------------------------------------+"
echo "|                  ______      _                                    |"
echo "|                 (_____ \    (_)                                   |"
echo "|                  _____) )___ _ _   _ _   _ _   _                  |"
echo "|                 |  ____/ ___) | | | | | | ( \ / )                 |"
echo "|                 | |   | |   | |\ V /| |_| |) X (                  |"
echo "|                 |_|   |_|   |_| \_/  \____(_/ \_)                 |"
echo "|                                                                   |"
echo "+-------------------------------------------------------------------+"

if [ -z $1 ]
then
	echo Es muss ein Name angegeben werden!
else

	echo Privater Schluessel fuer \"$1\" wird erstellt
	openssl genrsa -out ssl/private/$1.key 4096

	echo Zertifizierungsanfrage wird gestellt
	openssl req -new -config caconf.ini -key ssl/private/$1.key -out ssl/public/$1.csr -sha512

	echo Das Zertifikat fuer \"$1\" wird jetzt signiert
	openssl x509 -req -in ssl/public/$1.csr -CA ca/public/milky-way-ca.pem -CAkey ca/private/milky-way.key -CAcreateserial -out ssl/public/$1.pem -days 1461 -sha512

	rm ssl/public/$1.csr

	echo Kombiniere Zertifikat mit dem CA public key
	cat ca/public/milky-way-ca.pem >> ssl/public/$1.pem
fi