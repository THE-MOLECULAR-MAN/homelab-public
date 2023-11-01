#!/bin/bash
# Tim H 2022

# https://stardewvalleywiki.com/Modding:Installing_SMAPI_on_Steam_Deck

cd "$HOME/Downloads" || exit 1
STARDEW_PATH="/home/deck/.local/share/Steam/steamapps/common/Stardew Valley"
wget "https://github.com/Pathoschild/SMAPI/releases/download/3.17.2/SMAPI-3.17.2-installer.zip"
unzip "SMAPI-*-installer.zip"
cd '/home/deck/Downloads/SMAPI 3.17.2 installer' || exit 2
unzip internal/unix/install.dat
./install\ on\ Linux.sh

# Install cheats mod
# https://www.nexusmods.com/stardewvalley/mods/4
cd "$HOME/Downloads" || exit 1
wget --output-document=CJBCheatsMenu.zip 'https://cf-files.nexusmods.com/cdn/1303/4/CJB%20Cheats%20Menu%201.32.1-4-1-32-1-1665449022.zip?md5=Raxh3lneTImphQupGj_5Lg&expires=1667153474&user_id=164588768&rip=108.7.232.101'
unzip CJBCheatsMenu.zip

mv CJBCheatsMenu "$STARDEW_PATH/Mods"
