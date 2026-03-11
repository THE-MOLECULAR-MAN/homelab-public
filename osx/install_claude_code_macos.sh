# Claude code instructions for non-technical teams

##############################################################################
# Installing Claude Code on MacOS
##############################################################################
curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

# verify that claude code is installed correctly
claude --version

##############################################################################
# Creating your first Claude Code project
##############################################################################
mkdir -p ~/example_claude_project
cd ~/example_claude_project
claude init

##############################################################################
# a better way to structure Claude projects
##############################################################################
mkdir -p ~/Claude_Code_Projects/
cd ~/Claude_Code_Projects/

# creating a new project:
mkdir -p project1
cd project1
claude init


##############################################################################
# An even better way to structure projects
##############################################################################
# Put them in Google Drive so they get backed up and are accessible from
# anywhere, and also so you can easily share them with collaborators
# by sharing the folder in Google Drive
#
# You have to have Google Drive for Desktop installed and running 
# on your Mac for this to work
cd "~/Google Drive/My Drive"
mkdir -p "Claude Code Projects"
cd "Claude Code Projects"

mkdir -p project1
cd project1
claude init

##############################################################################
# Making fancier apps with Claude Code - installing dependencies
##############################################################################
# Installing Homebrew - https://brew.sh/
# You may need to install Xcode Command Line Tools first:
# xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# check that Homebrew is installed correctly
brew --version

# Install NodeJS and npm
brew install node

# check that NodeJS and npm are installed correctly
node --version
npm --version

