#!/bin/bash
# Tim H 2022
# Installs a custom rolled velociraptor agent onto CentOS 7
# Designed for remote control via the Velociraptor server - separate package
# This should be done after using build-velociraptor-agent-for-centos-on-osx.sh
# Velociraptor agent does not listen on any ports
# References:
#   https://docs.velociraptor.app/docs/deployment/clients/#linux

##############################################################################
#   STEP 4:
#       INSTALLING THE VELOCIRAPTOR AGENT ON CENTOS 7
##############################################################################

set -e

# file you generated in build-velociraptor-agent-for-centos-on-osx.sh
# you can also just scp it over to the target
AGENT_URL="http://yourlocalwebserver/velociraptor_client_centos7.rpm"
RPM_FILENAME="velociraptor_client_centos7.rpm"

# download the agent from a local webserver or wherever you host it
curl --output "$RPM_FILENAME" "$AGENT_URL"

# remove potentially conflicting agents
sudo yum remove -y zabbix-agent nrpe nagios-common nagios-plugins \
                   zabbix-release fping wazuh-agent xinetd

# view any other potentially conflicting packages:
yum list installed | grep "zabbix\|nrpe\|nagios\|prtg\|veloc\|jumpcloud\|grafana\|check-mk\|wuzah\|xinetd"

# verify RPM's internal checksum
rpm -K "$RPM_FILENAME"

# install it
sudo yum install -y "$RPM_FILENAME"

# check running status
pgrep --list-full "velociraptor"
sudo systemctl status velociraptor_client

# look at logs if needed:
# grep -i veloc /var/log/syslog
# grep -C5 -i "veloc" /var/log/messages
