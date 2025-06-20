#!/bin/bash
# Tim H 2022

# downloading and installing the checkmk agent for OS X
# https://gist.github.com/catchdave/44c45e31951fcc9ee4fb8768f4d95f21

set -e

cd "$HOME/source_code/third_party" || exit 1

# remove previous run stuff:
sudo rm -Rf Check_Mk install_check_mk_osx.sh check_mk_agent.macosx \
    /usr/local/lib/check_mk_agent \
    /Library/LaunchDaemons/de.mathias-kettner.check_mk.plist \
    /usr/local/lib/check_mk_agent/check_mk_agent.macosx \
    /usr/local/bin/check_mk_agent \
    /etc/check_mk \
    /var/run/de.arts-others.softwareupdatecheck \
    /var/log/check_mk.err

# download config file from my server?
# wget -O check_mk_agent.macosx   "[redacted]/check_mk_agent.macosx"

# download third party script
# wget -O install_check_mk_osx.sh "[redacted]/install_check_mk_osx.sh"

echo "finished downloading files."

chmod u+x install_check_mk_osx.sh

# do not use sudo since this script calls brew, which will exit 
# if in sudo
./install_check_mk_osx.sh

echo "my wrapper script finished successfully"

sudo cp -f /etc/pf.conf /etc/pf.conf.backup

sudo pfctl -d
echo "pass in inet proto tcp from any to any port 6556 no state" | \
    sudo tee -a /etc/pf.conf

sudo pfctl -f /etc/pf.conf

sudo pfctl -E

cat /Library/LaunchDaemons/de.mathias-kettner.check_mk.plist
# command shift G
/usr/local/lib/check_mk_agent/check_mk_agent.macosx
