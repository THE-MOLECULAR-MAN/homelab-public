#!/bin/bash
# Tim H 2023
#
#   This script installs and runs a tool that will automatically send hundreds
#   of friend invites for Fortnite to fellow listeners of the Get Played
#   podcast.
#
# WARNING: running this script WILL drop you from any active Epic Games on
# this account.
#
# Guide:
#   https://docs.google.com/document/d/13mG4h8soGDoFQT9lUZRJhSs2OuG9wzyNsbvKEpJe6CU/edit
# Get Played podcast Username spreadsheet:
#   https://docs.google.com/spreadsheets/d/1fttjmZG3ecQ5ClFkSCK9JxHmJJ5Dq7WUpxPaTQiZC0s/edit#gid=0
# GitHub repo:
#   https://github.com/indieisaconcept/gpbattlebus
# Live copy to run this in:
#   https://replit.com/@indieisaconcept/gpbattlebus
#
#
# not necessary to change directories since npm/npx will install to a hidden
# directory in the user's home path

# it's okay for these two commands to retun an error
npm ci
npm link

# install it
npx github:indieisaconcept/gpbattlebus

# locate where it is installed since it's not on PATH
# find ~/.npm -name '*gpbattlebus*' 2>/dev/null

# create an alias so I can easily call it
alias gpbattlebus="~/.npm/_npx/898e89c270b64674/node_modules/.bin/gpbattlebus"

# get played spreadsheet ID: 1fttjmZG3ecQ5ClFkSCK9JxHmJJ5Dq7WUpxPaTQiZC0s
GOOGLE_SHEET_ID="1fttjmZG3ecQ5ClFkSCK9JxHmJJ5Dq7WUpxPaTQiZC0s"
PROFILE_NAME="profile1"

# create and save profile, auto add everyone that hasn't been invited yet
# stores the creds so you don't have to re-enter them each time
gpbattlebus --reference "$GOOGLE_SHEET_ID" --mode auto --profile "$PROFILE_NAME" --save-profile

# check in on existing invites:
gpbattlebus --reference "$GOOGLE_SHEET_ID" --profile "$PROFILE_NAME"

# show Epic usernames for people who have accepted the invite:
gpbattlebus --reference "$GOOGLE_SHEET_ID" --profile "$PROFILE_NAME" | grep " │ CURRENT  │"

# count the number of friends successfully added from the sheet
gpbattlebus --reference "$GOOGLE_SHEET_ID" --profile profile1 | grep -c " │ CURRENT  │"
