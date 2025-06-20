#!/bin/bash
# Tim H 2021
# Adding an ESXi Host to a Microsoft Active Directory


# SET UP AD STUFF:

# Pre-flight checks:

# verifying that the  hostname is in fact an FQDN:
hostname

# making sure there aren't time sync problems between the domain controller and this host:
date    # view current date/time, CANNOT change timezone from UTC on ESXi
# go and check the date/time on the domain controller too in case it is off
# try powering off secondary domain controllers to avoid issues?

# show current network configuration
esxcli network ip interface ipv4 get

# verifying network connectivity between this host and the domain controller:
ping 10.0.1.11                  # basic network routing test
nc -v 10.0.1.11 389             # port open test
cat /etc/resolv.conf            # see where I get my DNS from
#nslookup -version              # doesn't  work on ESX busybox version, only on OS X and regular Linux
nslookup dc02.int.redacted.me   # test DNS lookup of domain controller
nslookup dc02                   # intentionally leaving out the domain to test DNS search settings
nslookup "$(hostname)"          # verify that this current host has a DNS entry
# verify PTR record (reverse DNS) for this host too, the IP is in reverse order:
nslookup -debug -type=ptr 13.1.0.10.in-addr.arpa    # this works on ESXi AND OS X

# check if ESXi host is currently joined to a domain
/usr/lib/vmware/likewise/bin/domainjoin-cli query       # just displays info,  doesn't make any changes

#################
#   Prep - make changes to PAM to allow joining AD
#################

# make a backup of course
cp /etc/pam.d/system-auth-generic /etc/pam.d/system-auth-generic.backup

# file is read-only by default, gotta make it writable first
# ls -lah   /etc/pam.d/system-auth-generic
# lsof | grep "/etc/pam.d/system-auth-generic"        # see if any processes have this file open, because the chmod fails sometimes

# some PAM related process running could block this:
# chmod u+w /etc/pam.d/system-auth-generic

# # changing the file may not be necessary:
# echo "#%PAM-1.0

# auth sufficient /lib/security/\$ISA/pam_lsass.so smartcard_prompt
# auth sufficient /lib/security/\$ISA/pam_unix.so try_first_pass likeauth nullok
# auth required /lib/security/\$ISA/pam_deny.so

# account sufficient /lib/security/\$ISA/pam_lsass.so smartcard_prompt
# account sufficient /lib/security/\$ISA/pam_unix.so
# account required /lib/security/\$ISA/pam_deny.so

# session sufficient /lib/security/\$ISA/pam_unix.so
# session required /lib/security/\$ISA/pam_deny.so" > /etc/pam.d/system-auth-generic

# # mark file as read only again
# chmod u-w /etc/pam.d/system-auth-generic 

# in GUI:
#   1) set the following services to autostart with host and start them:
#       SSH
#       Active Directory
#       Syslog server
#   2) 

#/etc/init.d/rhttpproxy restart
# these two were important
#/etc/init.d/hostd restart
#/etc/init.d/vpxa restart
/etc/init.d/lwsmd start # start the active directory service

# now go into the GUI and add it to the domain
