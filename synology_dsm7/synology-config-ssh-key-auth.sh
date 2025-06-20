#!/bin/bash
# Tim H 2022

# https://blog.aaronlenoir.com/2018/05/06/ssh-into-synology-nas-with-ssh-key/
# https://superuser.com/questions/1137438/ssh-key-authentication-fails

# ssh -vvvv -i ~/.ssh/redacted redacted@synology.int.butters.me

mkdir -p ~/.ssh
chmod 700 ~/.ssh/

touch ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

chown -R $USER:users ~/.ssh

# the most important part:
chmod 755 /volume1/homes/redacted

ls -lahd /volume1/homes/redacted ~ ~/.ssh/ ~/.ssh/authorized_keys

# should look like this when working:
# redacted@synology:~$ ls -lahd /volume1/homes/redacted ~ ~/.ssh/ ~/.ssh/authorized_keys
# drwxr-xr-x 1 redacted users  574 Oct 31 09:09 /var/services/homes/redacted
# drwx------ 1 redacted users   52 Oct 31 09:09 /var/services/homes/redacted/.ssh/
# -rw-r--r-- 1 redacted users 4.1K Oct 31 09:34 /var/services/homes/redacted/.ssh/authorized_keys
# drwxr-xr-x 1 redacted users  574 Oct 31 09:09 /volume1/homes/redacted

# sudo vim /etc/ssh/sshd_config
# grep 'SyslogFacility\|LogLevel' /etc/ssh/sshd_config

# nothing about ssh failures gets logged, even with the right settings:
# clear && tail --lines=1 -f /var/log/*.log
