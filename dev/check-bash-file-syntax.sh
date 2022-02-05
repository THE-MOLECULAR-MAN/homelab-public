#!/bin/bash
# Tim H 2019
# READY_FOR_PUBLIC_REPO
#	Displays all Bash Lint issues from .sh files in this repo
#
set -e

# basic way
# find ".." -not -path "*third-party*" -type f -iname '*.sh'  \
#    -exec shellcheck {} \;

# find ".." -not -path "*third-party*" -type f -iname '*.sh'  -exec shellcheck --severity=error {} +;

# better way that is 25% faster than the -exec version:
find ".." -not -path "*third-party*" -type f -iname '*.sh' -print0 \
    | xargs -0 shellcheck
