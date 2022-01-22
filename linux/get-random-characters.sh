#!/bin/bash
# Tim H 2011
# generates true random alphanumeric characters from random.org
# limit 1,000,000 per day per public IP via random.org site
#
# Example usage:
#   ./get-random-characters.sh 8
#
# References:
#   https://www.random.org/strings/?mode=advanced

numchars=$1

# Random.org has a limit on the number of columns: 20
# if someone requests more than 20 characters then it must be split into multiple rows
if [ "$numchars" -le 20 ]; then
    num_rows=1
    num_cols=$numchars
else
	num_rows=$(((numchars / 20) + 1))
	num_cols=20
fi

# must be HTTPS
random_url="https://www.random.org/strings/?num=$num_rows&len=$num_cols&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new"

# Linux version:
#curl -s "$random_url" 2>&1 | tr -d '\n' | head --bytes="$numchars"

# OS X and Linux version:
# pull it down, remove any new lines, and limit the number of characters to the requested ones.
curl -s "$random_url" 2>&1 | tr -d '\n' | head -c "$numchars"
