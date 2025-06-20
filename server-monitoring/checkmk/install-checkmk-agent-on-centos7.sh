#!/bin/bash
# Tim H 2022
# Installing the checkmk agent on CentOS 7

# CheckMK is listening on TCP 6556 (verified)
# incoming connections should be coming from 10.0.1.24 (verified)

# https://docs.checkmk.com/latest/en/agent_linux.html
# https://medium.com/@anuketjain007/how-to-install-check-mk-agent-in-centos-6-7-8-techoism-com-ec377a18a78a
# https://kifarunix.com/how-to-install-checkmk-monitoring-agents-on-linux/
# https://docs.checkmk.com/latest/en/wato_monitoringagents.html

# installing the agent in CentOS 7:
# DOWNLOAD THE RPM FROM THE WEB INTERFACE AFTER BAKING IT!!!! 
CHECKMK_CENTOS_AGENT_URL="http://installers.int.butters.me:8081/check-mk-agent-vanilla.rpm"
# CHECKMK_CENTOS_AGENT_URL="http://installers.int.butters.me:8081/check-mk-agent-generic.rpm"

RPM_FILENAME="check-mk-agent-centos.noarch.rpm"

curl --output "$RPM_FILENAME" "$CHECKMK_CENTOS_AGENT_URL"

# remove potentially conflicting agents
yum list installed | grep "zabbix\|nrpe\|nagios\|prtg\|veloc\|jumpcloud\|grafana\|check-mk\|wuzah\|xinetd"
sudo yum remove -y zabbix-agent nrpe nagios-common nagios-plugins zabbix-release fping wazuh-agent xinetd

# verify hashsum built into RPM file, see what the content is, make sure it is not HTML
rpm -K "$RPM_FILENAME"
file "$RPM_FILENAME"

# open the firewall for inbound connections
sudo firewall-cmd --state
sudo systemctl status firewalld
sudo firewall-cmd --zone=public --add-port=6556/tcp --permanent
sudo firewall-cmd --reload


##############################################################################
# install the baked agent
##############################################################################
sudo yum install -y "$RPM_FILENAME"

# post install checks:
systemctl status    check-mk-agent.socket
systemctl enable    check-mk-agent.socket

yum list installed | grep check-mk

check_mk_agent
/bin/check_mk_agent | grep -i checkmk.int.butters.me

# check for listening ports
sudo netstat -tulpn | grep 6556
lsof | grep 6556

# try rebooting and see if service comes back
