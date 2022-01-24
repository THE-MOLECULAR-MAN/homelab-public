#!/bin/bash
# Tim H 2022
# Set up crons for muting and unmuting the audio
# My dog gets scared of Slack sounds at night

PATH_TO_REPO="$HOME/source_code/homelab-public"

chmod u+x "$PATH_TO_REPO/osx/osx-unmute-audio.sh"
chmod u+x "$PATH_TO_REPO/osx/osx-mute-audio.sh"

(crontab -l ; echo "00 21 * * * $PATH_TO_REPO/osx/osx-mute-audio.sh")   | sort --unique | crontab -
(crontab -l ; echo "30 8  * * * $PATH_TO_REPO/osx/osx-unmute-audio.sh") | sort --unique | crontab -
