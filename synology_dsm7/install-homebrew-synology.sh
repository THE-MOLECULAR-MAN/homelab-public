#!/bin/bash
# Tim H 2022
#
# Installs homebrew on Synology's Linux
# I think I uninstalled this since it caused issues after a while
# Consumes about 1.9 GB of disk space after install
#
# do not run "brew doctor" or "brew style --fix"
# it doesn't seem possible to create an alias or shell function with a space 
# in its name, so I can't alias "brew doctor" without aliasing "brew" as
# a whole.
#
# References:
#   https://community.synology.com/enu/forum/1/post/153781
#
# Step 1: add the SynoCommunity Package Source in the GUI
#           Package Center > Settings > Package Sources
#           add one with Name: SynoCommunity
#           Location: http://packages.synocommunity.com/
# Step 2: Open Package Manager in the GUI, search for Ruby and install it
# Step 3: run this script via SSH
#
# run these commands as the primary user you'll be using Homebrew as

# create the /home path, it doesn't exist by default on synology
sudo mkdir -p /home

# temporarily mount it to a permanent home
sudo mount -o bind "/volume1/homes/" /home

# ldd isn't installed on synology linux and homebrew does a check on it
# during the install, so create a fake version that returns what the 
# homebrew installer is looking for:
echo "#!/bin/bash
echo \"ldd 2.20\" " | sudo tee /bin/ldd

# mark it as executable. Synology linux seems to need the ugo
sudo chmod ugo+x /bin/ldd

# synology linux doesn't seem to respect the 'other', so have to 
# manually set current user as the owner
sudo chown "$(whoami)" /bin/ldd

# verify the file exists and is executable by all users
ls -lah /bin/ldd

# test the fakey script, it should output "ldd 2.20" without the quotes
/bin/ldd --version

# Download and install Brew
# do not run this command as the root user or with sudo
# it will prompt for sudo password
# it's possible to do automated by prepending this to the next line:
#   NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# post install config:
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /var/services/homes/sshuser/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# HOMEBREW_GIT_PATH
brew --version

# pre-reqs for other things:
brew install git gcc ruby-build libyaml ruby make less coreutils jq cmake \
    python-build tree libmpd automake

#echo "export PATH=\"/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\$PATH\" " | sudo tee -a /etc/profile
#echo "export RUBY_CONFIGURE_OPTS=\"--with-openssl-dir=$(brew --prefix openssl@1.1)\" "        | sudo tee -a /etc/profile
#echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'                                 | sudo tee -a /etc/profile

echo "export PATH=\"/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\$PATH\" " >> ~/.profile
echo "export RUBY_CONFIGURE_OPTS=\"--with-openssl-dir=$(brew --prefix openssl@1.1)\" "        >> ~/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'                                 >> ~/.profile

#echo "export PATH=\"/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\$PATH\" "   | sudo tee -a /etc.defaults/.bashrc_profile
#echo "export RUBY_CONFIGURE_OPTS=\"--with-openssl-dir=$(brew --prefix openssl@1.1)\" "          | sudo tee -a /etc.defaults/.bashrc_profile
#echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'                                   | sudo tee -a /etc.defaults/.bashrc_profile

#echo "export PATH=\"/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\$PATH\" "   | sudo tee -a /root/.profile
#echo "export RUBY_CONFIGURE_OPTS=\"--with-openssl-dir=$(brew --prefix openssl@1.1)\" "          | sudo tee -a /root/.profile
#echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'                                   | sudo tee -a /root/.profile

sudo cp /root/.profile /root/.profile.backup
sudo cp /var/services/homes/sshuser/.profile /var/services/homes/sshuser/.profile.backup
sudo cp /etc.defaults/.bashrc_profile /etc.defaults/.bashrc_profile.backup
sudo cp /etc/profile /etc/profile.backup

# symlink more things that I can't fix the PATH env variable for:
sudo ln -s /home/linuxbrew/.linuxbrew/bin/make                                      /bin/make
sudo ln -s /home/linuxbrew/.linuxbrew/bin/gcc-12                                    /bin/gcc
sudo ln -s /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/shims/super/cc      /bin/cc

# Step 4: Add this as a start-up script
#   DSM > Control Panel > Task Scheduler > Create > Triggered Task > 
#       > User defined script
#   set the User as root
#   paste this in without the single leading #
# #!/bin/sh
# sleep 10
# mount -o bind "/volume1/homes" /home

# Step 5: reboot the DSM
# verify that brew still works
