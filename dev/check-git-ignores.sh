#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
# List all the files that are being ignored by git and why
# should be run from the dev directory
# TODO: change to use env variables and get rid of path requirement
# Example usage:
#   cd homelab/dev && ./check-git-ignores.sh

find .. -type f -exec git check-ignore -v {} +
