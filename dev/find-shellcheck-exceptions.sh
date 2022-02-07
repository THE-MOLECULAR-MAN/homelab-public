#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
# 
# Find all the shellcheck exceptions in bash files in repo
# don't include the current file

find .. -type f -iname '*.sh' ! -name "$(basename "$0")" \
    -exec grep -H --colour=auto --after-context=1 \
    --line-number "shellcheck disable" {} \;
