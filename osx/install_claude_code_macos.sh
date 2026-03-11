##############################################################################
# Installing Claude Code on MacOS
##############################################################################
curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
  
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



##############################################################################
# Making fancier apps with Claude Code - installing dependencies
##############################################################################
# Installing Homebrew - https://brew.sh/
# You may need to install Xcode Command Line Tools first:
# xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# checking that Homebrew is installed correctly
brew --version

# Installing NodeJS and npm
brew install node

# checking that NodeJS and npm are installed correctly
node --version
npm --version

