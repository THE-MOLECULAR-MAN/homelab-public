#!/bin/bash
# Tim H 2023

ssh tim-steam-deck.int.butters.me
STEAM_DECK_PATH="/home/deck/.config/unity3d/Lazy Bear Games/Graveyard Keeper"
BACKUP_PATH_TARGET="/volume1/tim_carrie_shared/Video_Games/Saved_Games_and_Backups/PC/graveyard_keeper"
# SYM_LINK_TO_SAVED_GAME="/home/deck/graveyard_keeper_saved_games_link"
# ln -s "$STEAM_DECK_PATH" "$SYM_LINK_TO_SAVED_GAME"


cd "$STEAM_DECK_PATH" || exit 1
# is rsync better?
scp -O ./*  thrawn@synology.int.butters.me:"$BACKUP_PATH_TARGET"

# on the gaming desktop



# sync back from synology to the steam deck:
cd "$STEAM_DECK_PATH" || exit 1
scp -O thrawn@synology.int.butters.me:"$BACKUP_PATH_TARGET/*" .  
