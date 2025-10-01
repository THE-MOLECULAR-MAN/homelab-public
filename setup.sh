#!/bin/zsh
# Tim H 2025

set -e # bail on error
echo "Starting setup script for homelab-public..."

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || exit 1


git config --global core.fileMode true

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --formula --quiet python@3.11 cmake wget git pyenv pyenv-virtualenv tmux exiftool

# Ubuntu
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        sudo apt-get update
        sudo apt install -y build-essential cmake wget git gh python3.11 virtualenv python3.11-venv python3.11-distutils ccache distcc cron
    elif [[ "$ID" == "almalinux" ]]; then
        sudo dnf install -y python3.11 cmake wget git gh
    elif [[ "$ID" == "steamos" ]]; then
        sudo steamos-readonly disable
        sudo pacman --noconfirm -S base-devel gcc screen tmux noto-fonts noto-fonts-extra noto-fonts-cjk git github-cli python-pip python-virtualenv
        python -m virtualenv .venv
    else
        echo "Other Linux: $ID"
        exit 1
    fi

else
    echo "Unknown OS"
    exit 2
fi

if [ ! -d .venv ]; then
    echo "Creating new virtual environment..."
    python3.11 -m pip install --upgrade virtualenv
    python3.11 -m virtualenv .venv
fi

source .venv/bin/activate
pip install --quiet --upgrade -r requirements.txt
deactivate

echo "Successfully finished setup script for homelab-public."
