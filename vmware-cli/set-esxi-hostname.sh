#!/bin/bash
# Tim H 2021
# Setting an ESXi hosts's hostname and FQDN
# There's an easier way in the GUI in vSphere and ESXi:
#   https://kb.vmware.com/s/article/1010821

# safely shut down all virtual machines to prepare for reboot
# restart the ESXi web service
#https://kb.vmware.com/s/article/2144962
#https://kb.vmware.com/s/article/2084629

# Fixing this error: "The host failed to join the domain The host does not have a suitable FQDN"

NEW_HOSTNAME="microserver"
NEW_DOMAIN="INT.REDACTED.ME"                             # INT.CONTOSO.COM must be in ALL CAPS

# CAUTION: ESX doesn't like the tabs in this file, use spaces instead.
# Caution, this  is a super sensitive file and the order of everything matters a LOT: https://kb.vmware.com/s/article/1005750
# localhost MUST be the LAST thing on the line
echo "# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1   $NEW_HOSTNAME.$NEW_DOMAIN $NEW_HOSTNAME localhost
::1         $NEW_HOSTNAME.$NEW_DOMAIN $NEW_HOSTNAME localhost" > /etc/hosts
#!!!!!! ^ fixing this file fixed the issue and allowed it to join the domain. It still displayed an error message about something tho

# In the GUI:
# Networking > Default TCP/IP Stack > Settings
#   set the hostnamne to the first short name
#   set the domain name as the Domain ($NEW_DOMAIN)

# restart ALL services on ESXi (not VMs) - this takes a minute but seems to fix things
services.sh restart

hostname

# cp /etc/vmware/rhttpproxy/endpoints.conf /etc/vmware/rhttpproxy/endpoints.bkp
# grep "ui\|8308" /etc/vmware/rhttpproxy/endpoints.conf

# does this reboot things?
# esxcfg-advcfg -s "$NEW_HOSTNAME.$NEW_DOMAIN" /Misc/hostname
