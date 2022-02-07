#!/bin/bash
# Tim H 2020
# READY_FOR_PUBLIC_REPO
# script to remove the git version of locally deleted files in a git repo
# References:
#	https://superuser.com/questions/284187/bash-iterating-over-lines-in-a-variable
# 	https://stackoverflow.com/questions/35927760/bash-script-loop-through-shell-output
# 	https://stackoverflow.com/questions/25826752/using-tr-to-replace-newline-with-space

# should do a commit/push first so the "deleted: " doesn't show up for already
git status | grep "deleted:" | cut -d: -f2 | sed 's/^ *//g' | while read -r line ; do
   #git rm --dry-run "$line"
	git rm "$line"
done
