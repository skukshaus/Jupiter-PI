#!/bin/sh
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
# Provides:          iptables
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Firewall Script
# Description:       Regelt Datenzugriffe auf den PI und das gesammte Netzwerk
### END INIT INFO

configure_forward_chain() {
	#iptables -A FORWARD -p tcp --dport  21 -j ACCEPT	# FTP
	#iptables -A FORWARD -p tcp --dport  21 -j ACCEPT	# FTP
	iptables -A FORWARD -p tcp --dport  22 -j ACCEPT	# SSH
	iptables -A FORWARD -p tcp --dport  25 -j ACCEPT	# SMTP
	iptables -A FORWARD -p tcp --dport  53 -j ACCEPT	# DNS
	iptables -A FORWARD -p udp --dport  53 -j ACCEPT	# DNS
	iptables -A FORWARD -p tcp --dport  80 -j ACCEPT	# HTTP
	iptables -A FORWARD -p tcp --dport 110 -j ACCEPT	# POP3
	iptables -A FORWARD -p udp --dport 123 -j ACCEPT	# NTP
	iptables -A FORWARD -p tcp --dport 143 -j ACCEPT	# IMAP
	iptables -A FORWARD -p udp --dport 143 -j ACCEPT	# IMAP
	iptables -A FORWARD -p tcp --dport 443 -j ACCEPT	# HTTPs
	iptables -A FORWARD -p tcp --dport 465 -j ACCEPT	# SMTPs
	iptables -A FORWARD -p tcp --dport 587 -j ACCEPT	# submission
	iptables -A FORWARD -p tcp --dport 993 -j ACCEPT	# IMAPs	
	iptables -A FORWARD -p tcp --dport 995 -j ACCEPT	# POP3s
	
	# Google Play (für Androids und so)
	iptables -A FORWARD -p tcp --dport 9000 -j ACCEPT
	iptables -A FORWARD -p tcp --dport 9300 -j ACCEPT
	iptables -A FORWARD -p tcp --dport 9339 -j ACCEPT
	iptables -A FORWARD -p tcp --dport 4234 -j ACCEPT
	iptables -A FORWARD -p tcp --dport 9050 -j ACCEPT
	
	iptables -A FORWARD -p tcp --dport 5222 -j ACCEPT # XMPP
		
	iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	iptables -A FORWARD -j LOG --log-prefix "[FW-F] "
	iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
}

configure_input_chain() {
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	# GANZ wichtig um sich nicht aus Versehen auszusperren, wenn man per PuTTy
	# am Raspberry arbeitet!!! SSH darf aber nur aus dem lokalen Netzwerk zugänglich
	# sein. Also nicht per WLAN. Da könnte sich ja sonst wer darauf verbinden
	# ist zwar etwas unwahrscheinlich, aber sicher ist sicher :-)
	iptables -A INPUT -i eth1 -p tcp --dport 22 -j ACCEPT
	
	iptables -A INPUT -p udp --dport 137 -j ACCEPT	# NetBIOS Name Service
	iptables -A INPUT -p dup --dport 138 -j ACCEPT	# NetBIOS Datagram Service
	iptables -A INPUT -p tcp --dport 139 -j ACCEPT	# NetBIOS Session Service
	iptables -A INPUT -p tcü --dport 445 -j ACCEPT	# SMB Freigaben
	
	iptables -A INPUT -p tcp --dport  80 -j ACCEPT	# HTTP
	iptables -A INPUT -p tcp --dport 443 -j ACCEPT	# HTTPs
	
	iptables -A INPUT -p tcp --dport  53 -j ACCEPT	# DNS
	iptables -A INPUT -p udp --dport  53 -j ACCEPT	# DNS
	iptables -A INPUT -p tcp --dport 953 -j ACCEPT	# DNS RNDC Service
	
	iptables -A INPUT -p tcp --dport 3128 -j ACCEPT	# Squid
	
	iptables -A INPUT -p udp --dport 67 -j ACCEPT	# DHCP
	iptables -A INPUT -p udp --dport 68 -j ACCEPT	# DHCP
	iptables -A INPUT -p udp --dport 69 -j ACCEPT	# DHCP
	
	iptables -A INPUT -p tcp --dport 631 -j ACCEPT	# IPP
	iptables -A INPUT -p udp --dport 631 -j ACCEPT	# IPP
	
	# Ankommenden Traffic loggen
	iptables -A INPUT -j LOG --log-prefix "[FW-I] "
	iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
}

configure_output_chain() {
	# Ausgehenden Traffic an das Netzwerk erlauben
	iptables -A OUTPUT -o lo -j ACCEPT
	iptables -A OUTPUT -o eth1 -j ACCEPT
	iptables -A OUTPUT -o wlan0 -j ACCEPT
	iptables -A OUTPUT -o wlan1 -j ACCEPT
	
	iptables -A OUTPUT -p tcp -m tcp --sport 53:65535 --dport 53 -j ACCEPT
	iptables -A OUTPUT -p udp -m udp --sport 53:65535 --dport 53 -j ACCEPT

	
	iptables -A OUTPUT -p tcp -m multiport --dport 80,443 -j ACCEPT
	iptables -A OUTPUT -p udp -m multiport --dport 80,443 -j ACCEPT
	# SPAMMY
	iptables -A OUTPUT -o eth0 -p udp --dport 631 -j REJECT
	
	# Ungewollten ausgehenden Traffic loggen
	iptables -A OUTPUT -j LOG --log-prefix "[FW-O] "
	# und natürlich sperren :-)
	iptables -A OUTPUT -j REJECT --reject-with icmp-host-prohibited
}

configure_postrouting() {
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

configure_hardening() {
    # TCP Syn Flood
    iptables -A INPUT -p tcp --syn -m limit --limit 3/s -j ACCEPT
    # UDP Syn Flood
    iptables -A INPUT -p udp -m limit --limit 10/s -j ACCEPT
    # Ping Flood
    iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-reply -m limit --limit 1/s -j ACCEPT
    #
    echo "TCP, UDP, ICMP Flood is now limited!"
}

flush() {
	iptables -F
	iptables -X
	iptables -F -t mangle
	iptables -F -t nat

	iptables -F INPUT
	iptables -F FORWARD
	iptables -F OUTPUT
}

fwstop() {
	flush

	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT

	#fwprint
}
fwstart() {
	flush
	
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	
	configure_hardening
	configure_input_chain
	configure_forward_chain
	configure_output_chain
	configure_postrouting
	
	fwprint
}

fwprint() {
	iptables -L -v
}



case "$1" in
	start)
		echo "starting firewall";
		fwstart
	;;
	stop)
		echo "stoping firewall";
		fwstop
	;;
	restart)
		echo "stoping firewall";
		fwstop

		echo "starting firewall";
		fwstart
	;;
esac
exit 0