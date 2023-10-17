#!/bin/bash
# Tim H 2023

# install and set up for Spiderfoot
# https://github.com/smicallef/spiderfoot

python3 -m venv ~/source_code/third_party/spiderfoot_venv

cd ~/source_code/third_party/spiderfoot_venv || exit
source ./bin/activate

wget https://github.com/smicallef/spiderfoot/archive/v4.0.tar.gz
tar zxvf v4.0.tar.gz
cd spiderfoot-4.0 || exit
pip3 install -r requirements.txt
python3 ./sf.py -l 127.0.0.1:5001
