#!/bin/bash
# Tim H 2022
# checkmk email settings

# https://docs.checkmk.com/latest/en/notifications.html#smtp
# https://docs.checkmk.com/latest/en/appliance_usage.html#_configuring_outgoing_emails

sudo apt-get update
sudo apt-get -y install mailutils

sudo vim /etc/postfix/main.cf
    # relayhost = [smtp.int.butters.me]:25
    # mynetworks = localhost, 10.0.1.0/24, 127.0.0.1

sudo systemctl restart postfix.service

echo "test email from command line on $HOSTNAME at $(date)" | mail -s checkmk-test-subject REDACTED@gmail.com


# watching log for debugging:
tail -f /opt/omd/sites/homelab2/var/log/notify.log


# 2022-09-07 22:20:52,737 [20] [cmk.base.notify] 1 rules matched, but no notification has been created.
