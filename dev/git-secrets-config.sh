#!/bin/bash
# Tim H 2020
# Initial setup for Git secrets
# READY_FOR_PUBLIC_REPO

set -e

echo "started script..."

cd ~/source_code/homelab || exit 1
git secrets --register-aws --global

# Add hooks to all your local repositories.

git secrets --install ~/.git-templates/git-secrets
git config --global init.templateDir ~/.git-templates/git-secrets

# Add custom providers to scan for security credentials.

git secrets --add-provider -- cat banned_words.txt

echo "Script finished successfully."
