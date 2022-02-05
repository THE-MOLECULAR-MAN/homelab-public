#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
# searches for banned phrases in files in repo
# checks all files outside of the .git/ directory
#
# Example usage:
#   ./check-banned-phrases.sh

REPO_HOME="$HOME/source_code/homelab"

find "$REPO_HOME" -type f ! -iname 'banned_words.txt'  ! -path  '*.git/*' | while read -r FILE; do
	while read -r banned_phrase; do
		if grep -qi "$banned_phrase" "$FILE" ; then
			echo -e "$banned_phrase\t\t$FILE"
			echo -e "\t\t $(grep "$banned_phrase" "$FILE")"
		fi
	done < "$REPO_HOME/banned_words.txt"
done || exit $?
