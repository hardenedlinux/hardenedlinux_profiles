#!/bin/sh

#------------------------------------------------------------------------------
#
# File: iptables_mint17.sh
#
# http://www.hardenedlinux.org
#
# Reference: Ruslan Abuzant <ruslan@abuzant.com>,  http://www.hackersgarage.com/
#
# License: GNU GPL (version 2, or any later version).
#
# Configuration.
#------------------------------------------------------------------------------

# For debugging use iptables -v.
IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"
MODPROBE="/sbin/modprobe"
RMMOD="/sbin/rmmod"
ARP="/usr/sbin/arp"

# NIC interfaces
NIC_NAME="eth0 wlan0"

# Logging options.
#------------------------------------------------------------------------------
LOG="LOG --log-level debug --log-tcp-sequence --log-tcp-options"
LOG="$LOG --log-ip-options"


# Defaults for rate limiting
#------------------------------------------------------------------------------
RLIMIT="-m limit --limit 3/s --limit-burst 8"


# Unprivileged ports.
#------------------------------------------------------------------------------
PHIGH="1024:65535"
PSSH="1000:1023"


# Load required kernel modules
#------------------------------------------------------------------------------
$MODPROBE ip_conntrack_ftp
$MODPROBE ip_conntrack_irc


# Mitigate ARP spoofing/poisoning and similar attacks.
#------------------------------------------------------------------------------
# Hardcode static ARP cache entries here
# $ARP -s IP-ADDRESS MAC-ADDRESS


# Default policies.
#------------------------------------------------------------------------------

# Drop everything by default.
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT

# Set the nat/mangle/raw tables' chains to ACCEPT

$IPTABLES -t mangle -P PREROUTING ACCEPT
$IPTABLES -t mangle -P INPUT ACCEPT
$IPTABLES -t mangle -P FORWARD ACCEPT
$IPTABLES -t mangle -P OUTPUT ACCEPT
$IPTABLES -t mangle -P POSTROUTING ACCEPT

# Cleanup.
#------------------------------------------------------------------------------

# Delete all
$IPTABLES -F
$IPTABLES -t mangle -F

# Delete all
$IPTABLES -X
$IPTABLES -t mangle -X

# Zero all packets and counters.
$IPTABLES -Z
$IPTABLES -t mangle -Z

# Completely disable IPv6.
#------------------------------------------------------------------------------

# Block all IPv6 traffic
# If the ip6tables command is available, try to block all IPv6 traffic.
if test -x $IP6TABLES; then
# Set the default policies
# drop everything
$IP6TABLES -P INPUT DROP 2>/dev/null
$IP6TABLES -P FORWARD DROP 2>/dev/null
$IP6TABLES -P OUTPUT DROP 2>/dev/null

# The mangle table can pass everything
$IP6TABLES -t mangle -P PREROUTING ACCEPT 2>/dev/null
$IP6TABLES -t mangle -P INPUT ACCEPT 2>/dev/null
$IP6TABLES -t mangle -P FORWARD ACCEPT 2>/dev/null
$IP6TABLES -t mangle -P OUTPUT ACCEPT 2>/dev/null
$IP6TABLES -t mangle -P POSTROUTING ACCEPT 2>/dev/null

# Delete all rules.
$IP6TABLES -F 2>/dev/null
$IP6TABLES -t mangle -F 2>/dev/null

# Delete all chains.
$IP6TABLES -X 2>/dev/null
$IP6TABLES -t mangle -X 2>/dev/null

# Zero all packets and counters.
$IP6TABLES -Z 2>/dev/null
$IP6TABLES -t mangle -Z 2>/dev/null
fi

# Custom user-defined chains.
#------------------------------------------------------------------------------

# LOG packets, then ACCEPT.
$IPTABLES -N ACCEPTLOG
$IPTABLES -A ACCEPTLOG -j $LOG $RLIMIT --log-prefix "ACCEPT "
$IPTABLES -A ACCEPTLOG -j ACCEPT

# LOG packets, then DROP.
$IPTABLES -N DROPLOG
$IPTABLES -A DROPLOG -j $LOG $RLIMIT --log-prefix "DROP "
$IPTABLES -A DROPLOG -j DROP

# LOG packets, then REJECT.
# TCP packets are rejected with a TCP reset.
$IPTABLES -N REJECTLOG
$IPTABLES -A REJECTLOG -j $LOG $RLIMIT --log-prefix "REJECT "
$IPTABLES -A REJECTLOG -p tcp -j REJECT --reject-with tcp-reset
$IPTABLES -A REJECTLOG -j REJECT

# Only allows RELATED ICMP types
# (destination-unreachable, time-exceeded, and parameter-problem).
# TODO: Rate-limit this traffic?
# TODO: Allow fragmentation-needed?
# TODO: Test.
$IPTABLES -N RELATED_ICMP
$IPTABLES -A RELATED_ICMP -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPTABLES -A RELATED_ICMP -p icmp --icmp-type time-exceeded -j ACCEPT
$IPTABLES -A RELATED_ICMP -p icmp --icmp-type parameter-problem -j ACCEPT
$IPTABLES -A RELATED_ICMP -j DROPLOG

# Make It Even Harder To Multi-PING
$IPTABLES  -A INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j ACCEPT
$IPTABLES  -A INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j LOG --log-prefix PING-DROP:
$IPTABLES  -A INPUT -p icmp -j DROP
$IPTABLES  -A OUTPUT -p icmp -j ACCEPT

# Only allow the minimally required/recommended parts of ICMP. Block the rest.
#------------------------------------------------------------------------------

# TODO: This section needs a lot of testing!

# First, drop all fragmented ICMP packets (almost always malicious).
$IPTABLES -A INPUT -p icmp --fragment -j DROPLOG
$IPTABLES -A OUTPUT -p icmp --fragment -j DROPLOG
$IPTABLES -A FORWARD -p icmp --fragment -j DROPLOG

# Allow all ESTABLISHED ICMP traffic.
$IPTABLES -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT $RLIMIT
$IPTABLES -A OUTPUT -p icmp -m state --state ESTABLISHED -j ACCEPT $RLIMIT

# Allow some parts of the RELATED ICMP traffic, block the rest.
$IPTABLES -A INPUT -p icmp -m state --state RELATED -j RELATED_ICMP $RLIMIT
$IPTABLES -A OUTPUT -p icmp -m state --state RELATED -j RELATED_ICMP $RLIMIT

# Allow incoming ICMP echo requests (ping), but only rate-limited.
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT $RLIMIT

# Allow outgoing ICMP echo requests (ping), but only rate-limited.
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT $RLIMIT

# Drop any other ICMP traffic.
$IPTABLES -A INPUT -p icmp -j DROPLOG
$IPTABLES -A OUTPUT -p icmp -j DROPLOG
$IPTABLES -A FORWARD -p icmp -j DROPLOG

# Selectively allow certain special types of traffic.
#------------------------------------------------------------------------------

# Allow loopback interface to do anything.
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

# Allow incoming connections related to existing allowed connections.
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections EXCEPT invalid
$IPTABLES -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Miscellaneous.
#------------------------------------------------------------------------------

# We don't care about Milkosoft, Drop SMB/CIFS/etc..
$IPTABLES -A INPUT -p tcp -m multiport --dports 135,137,138,139,445,1433,1434 -j DROP
$IPTABLES -A INPUT -p udp -m multiport --dports 135,137,138,139,445,1433,1434 -j DROP

# Explicitly drop invalid incoming traffic
$IPTABLES -A INPUT -m state --state INVALID -j DROP

# Drop invalid outgoing traffic, too.
$IPTABLES -A OUTPUT -m state --state INVALID -j DROP

# If we would use NAT, INVALID packets would pass - BLOCK them anyways
$IPTABLES -A FORWARD -m state --state INVALID -j DROP

# PORT Scanners (stealth also)
$IPTABLES -A INPUT -m state --state NEW -p tcp --tcp-flags ALL ALL -j DROP
$IPTABLES -A INPUT -m state --state NEW -p tcp --tcp-flags ALL NONE -j DROP

# TODO: Some more anti-spoofing rules? For example:
# $IPTABLES -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
# $IPTABLES -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
# $IPTABLES -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
$IPTABLES -N SYN_FLOOD
$IPTABLES -A INPUT -p tcp --syn -j SYN_FLOOD
$IPTABLES -A SYN_FLOOD -m limit --limit 2/s --limit-burst 6 -j RETURN
$IPTABLES -A SYN_FLOOD -j DROP


# TODO: ICQ, MSN, GTalk, Skype, Yahoo, etc...

# Selectively allow certain inbound connections, block the rest.
#------------------------------------------------------------------------------

# Allow incoming SSH requests.
$IPTABLES -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT

# Explicitly log and reject everything else.
#------------------------------------------------------------------------------
# Use REJECT instead of REJECTLOG if you don't need/want logging.
$IPTABLES -A INPUT -j REJECTLOG
$IPTABLES -A OUTPUT -j REJECTLOG
$IPTABLES -A FORWARD -j REJECTLOG

# Counter hits

for i in $NIC_NAME
do
	iptables -I INPUT -p tcp -m multiport --dports 22 -i $i -m state --state NEW -m recent --set
	iptables -I INPUT -p tcp -m multiport --dports 22 -i $i -m state --state NEW -m recent --update --seconds 50 --hitcount 3 -j DROP
done

#------------------------------------------------------------------------------
# Testing the firewall.
#------------------------------------------------------------------------------

# You should check/test that the firewall really works, using
# iptables -vnL, nmap, ping, telnet, ...

# Exit gracefully.
#------------------------------------------------------------------------------

    exit 0
