#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
# Search my source code repos for something

# for some reason (GDrive mounting or symlink?) have to cd
#    there first, can't just search directly
cd "$HOME/source_code" || exit 1

find . -type f -iname '*.sh' -exec grep -i --color=always \
    --with-filename "$1" {} \;
