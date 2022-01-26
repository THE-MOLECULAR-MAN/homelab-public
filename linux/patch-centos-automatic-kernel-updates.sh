#!/bin/bash
# Tim H 2020
# CentOS - automatically patch kernel and run new one by rebooting
# installed as a daily cron
# References:
# 	https://blog.kernelcare.com/avoid-death-taxes-and-linux-server-reboots-kernel-updates-3-different-ways
# 	https://stackoverflow.com/questions/5885934/bash-function-to-find-newest-file-matching-pattern
# 	https://www.thegeekdiary.com/centos-rhel-begginners-guide-to-cron/
#	https://bencane.com/2014/09/02/understanding-exit-codes-and-how-to-use-them-in-bash-scripts/#:~:text=To%20check%20the%20exit%20code,of%20the%20last%20run%20command.&text=As%20you%20can%20see%20after,though%20the%20touch%20command%20failed.
#	https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf
#	https://stackoverflow.com/questions/26675681/how-to-check-the-exit-status-using-an-if-statement

set -e

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# install dependency for installing kernel updates w/o reboots
#yum install -y -q kexec-tools

# define a file path for the cron job
cron_filepath="/etc/cron.daily/update-kernel-reboot"

# output a script that does all the work
cat <<EOF > "$cron_filepath"
#!/bin/bash
# CentOS - automatically patch kernel and run new one by rebooting

set -e

if [ ! "\$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

old_kernel=\$(uname -r)

# check to see if kernel update is available, if not, then just bail
# if  returns 100 then updates are available
# if it returns 0 then no updates


#check if a kernel update is available and has not been installed yet
if  yum check-update -q kernel; then
    # there is no update available, error code = 0
    echo "no update available. Exiting."
    exit 0
fi

#echo "Kernel update found."
yum update -y -q kernel

# can't get the kexec stuff to work so gonna just force a reboot
#echo "rebooting to apply kernel changes"
reboot now

#latest_vmlinuz=\$(ls -t /boot/vmlinuz-* | head -1)
#latest_initrd=\$(ls -t /boot/initramfs-* | head -1)

#echo "Migrating from kernel version \$old_kernel
#to \$latest_vmlinuz and \$latest_initrd"

# clean up any other staged changes
#set +e
#kexec -u
#set -e

# apply the changes, update kernel without rebooting
#kexec -l -s "\$latest_vmlinuz" --initrd="\$latest_initrd" --reuse-cmdline

#echo "Running kernel now: \$(uname -r)"
#echo "Finish upgrading kernel without rebooting."

EOF

# output for debugging
#cat "$cron_filepath"

# change permissions so it can be run
chown root:root "$cron_filepath"
chmod 700 "$cron_filepath"

#ls -lah "$cron_filepath"
