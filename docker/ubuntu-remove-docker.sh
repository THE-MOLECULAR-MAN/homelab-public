# https://docs.ansible.com/ansible/latest/collections/community/docker/index.html

# test if docker is installed
# check if docker service is running
# test if any images are downloaded
# test if any containers exist
# test if any containers are running

# uninstall if true
# clean up apt to remove others

sudo docker image list --all

sudo apt-get purge -y docker* python3-docker*
sudo apt-get -y autoremove
sudo apt-get -y autoclean
sudo ifconfig docker0 down
sudo dpkg -l | grep docker | grep -v wmdocker
sudo systemctl daemon-reload
sudo reboot now
sudo rm -Rf /etc/docker /var/lib/docker /var/cache/apt/archives/*docker*

sudo find / -iname '*docker*' | grep -v 'ansible\|wmdocker'

#sudo service docker status
#sudo service --status-all
# reboot now
