curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
  
claude --version

mkdir -p ~/example_claude_project
cd ~/example_claude_project
claude init