#!/bin/bash
# Tim H 2022

rm /usr/local/include/node/v8-inspector-protocol.h
rm /usr/local/include/node/v8-inspector.h
rm /usr/local/include/node/v8-testing.h
rm /usr/local/include/python3.8/greenlet/greenlet.h

# have to unlink and relink things, --override doesn't do it on its own
brew link python@2
brew unlink imath && brew link imath
brew link ansible-lint
brew link ansible
brew link six

echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.bash_profile

# this was the nuclear option but it fixed the issue ansible Error: Permission denied @ apply2files - /usr/local/lib/docker/cli-plugins
sudo chown -R $(whoami):admin /usr/local/* \
&& sudo chmod -R g+rwx /usr/local/*

brew cleanup
