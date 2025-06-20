#!/bin/bash
# Tim H 2022
# uninstall JumpCloud agent from OS X manually

# Download the uninstaller:
wget "https://github.com/TheJumpCloud/support/releases/download/mac_agent_uninstaller/remove_mac_agent.sh"

# mark it as executable
chmod u+x remove_mac_agent.sh

# uninstall
sudo ./remove_mac_agent.sh
