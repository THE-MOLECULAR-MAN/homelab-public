#!/bin/bash
# Tim H 2022
# Pulls the latest list of bittorrent trackers from GitHub and
# then converts them into a list of Top Level Domains to blacklist on my DNS server
# OpenDNS free accounts have a limit of 25 blacklisted domains

OUTPUT_FILE="blacklist_FQDNs.txt"

rm -f "$OUTPUT_FILE" trackers_all.txt

wget https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt

for url in $(cat "trackers_all.txt")
do 
  # extract FQDN then TLD, also removes port numbers
  echo "$url" | awk -F[/:] '{print $4}' | awk -F"." '{print $(NF-1)"."$NF}' >> "$OUTPUT_FILE"
done

# sort them alphabetically and remove duplicates
sort --unique --output "$OUTPUT_FILE" "$OUTPUT_FILE" 
