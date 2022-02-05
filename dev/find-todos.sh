#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
# 
# Find all the TODOs in bash files in repo
# don't include the current file
# case sensitive for TODO, won't match todo

find .. -type f -iname '*.sh' ! -name "$(basename "$0")" -exec grep -H \
    --colour=auto --line-number "TODO" {} \;
