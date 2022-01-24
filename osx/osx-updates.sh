#!/bin/bash
# Tim H 2019-2021
#   
#   Script to run a variety of updates on an OS X system
#   Includes: OS X operating system updates, brew updates, pip3 updates
#   Commented out since they caused issues over time: npm (node.js), Docker
#	TODO: make this an Ansible playbook instead
#
#   References:
#       https://docs.npmjs.com/updating-packages-downloaded-from-the-registry
#
#   Example cron to run every 4 hours:
#   0 */4 * * *	$HOME/g_drive/bin/updates.sh
# Set up logging to external file

# bomb out if any errors
set -e

################################################################################
#		FUNCTION DEFINITIONS
################################################################################
THIS_SCRIPT_NAME=$(basename "$0")                 # can't use the --suffix since it isn't supported in OS X like it is in Linux
LOGFILE="$HOME/history-$THIS_SCRIPT_NAME.log"         # filename of file that this script will log to. Keeps history between runs.

friendlier_date () {
    #Looks like this: 2021-02-26 03:55:09 PM EST
	date +"%Y-%m-%d %I:%M:%S %p %Z"
}

log () {
	# formatted log output including timestamp
	#echo -e "[$THIS_SCRIPT_NAME] $(date)\t $@"
    echo -e "[$THIS_SCRIPT_NAME] $(friendlier_date)\t $*"
}


restart_Signal () {
	# kill all 5 processes
	pkill -f "/Applications/Signal.app/Contents/MacOS/Signal"
	# start it again and background it
	nohup /Applications/Signal.app/Contents/MacOS/Signal &>/dev/null &
}


################################################################################
#		MAIN PROGRAM
################################################################################

# Set up logging to external file
exec >> "$LOGFILE"
exec 2>&1

# start a log so I know it ran
log "========= START ============="

# have to define path since this runs as cron and the path variable doesn't work for some of the commands
PATH="$HOME/Google Drive File Stream/My Drive/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/Library/Python/2.7/bin:/Applications/VMware Fusion.app/Contents/Public"

# OS X update - download but don't install yet (may force reboot)
softwareupdate --download --recommended

# download list of latest Brew updates
# git -C "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask" fetch --unshallow     # might have to do this to fix things
brew update
# fix conflicts?
#cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core && git stash pop
# install the Brew updates
brew upgrade

# upgrade pip itself
#sudo /Library/Frameworks/Python.framework/Versions/3.9/bin/python3 -m pip install --upgrade pip

# Install any available updates for any pip3 packages
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install --quiet -U

# and then a bunch of commented out stuff that broke things over time
# ^ made me manually remove NPM and reinstall it :-(

# add support for updating Docker itself, maybe images
#docker-machine upgrade

##sudo npm cache clean -f
#npm cache verify
#sudo npm update
#sudo npm install --quiet npm@latest -g
#npm install -g npm

# have to run as root :-(
#for d in /usr/local/lib/node_modules/* ; do
#   #echo "$d"
#   cd "$d"
##   sudo npm cache clean -f
#   npm update --quiet
#   npm install --quiet
#   npm audit fix --quiet
#done

#du -sh $HOME/.npm/_logs
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#brew reinstall python
#brew install jsonlint sqlmap nmap
#brew install npm

# npm install npm-check-updates  swagger-cli 
# not finding this package: oas_converter

#If you need to have icu4c first in your PATH run:
#  echo 'export PATH="/usr/local/opt/icu4c/bin:$PATH"' >> ~/.bash_profile
#  echo 'export PATH="/usr/local/opt/icu4c/sbin:$PATH"' >> ~/.bash_profile

#For compilers to find icu4c you may need to set:
#  export LDFLAGS="-L/usr/local/opt/icu4c/lib"
#  export CPPFLAGS="-I/usr/local/opt/icu4c/include"

#curl -ksO https://gist.githubusercontent.com/nicerobot/2697848/raw/uninstall-node.sh
#chmod +x ./uninstall-node.sh
#./uninstall-node.sh
#rm uninstall-node.sh

#brew install nvm
#nvm install node
#/usr/local/lib/uninstall-node.sh

#brew install node
# i couldn't get node installed via brew or pip working
# gonna install it independently
#curl "https://nodejs.org/dist/latest/node-${VERSION:-$(wget -qO- https://nodejs.org/dist/latest/ | sed -nE 's|.*>node-(.*)\.pkg</a>.*|\1|p')}.pkg" > "$HOME/Downloads/node-latest.pkg" && sudo installer -store -pkg "$HOME/Downloads/node-latest.pkg" -target "/"


# restart affect applications
restart_Signal


log "==== SCRIPT ENDED SUCCESSFULLY ====="
