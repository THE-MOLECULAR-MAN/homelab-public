#!/usr/bin/env bash
# Tim H 2022

# Show env vars
grep -v '^#' .env

# Export env vars
export $(grep -v '^#' .env | xargs)
