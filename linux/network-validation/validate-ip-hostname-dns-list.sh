#!/bin/bash
# Tim H 2021
# shellcheck disable=SC2059
#
#   Description:
#       This script is designed to compare a live network (and DNS server) to a known state supplied in a CSV file.
#   You provide a CSV file (definitive-list-of-mac-ip-hostname.csv) with the columns in this order: MAC Address, Static or DHCP reservation IP address, Fully Qualified Domain Name
#   This script will output a space delimited table that lists the expected MAC, IP, and hostname and whether they were correct.
#
#   How this script works:
#       1) It clears the ARP table and runs a ping sweep of a network to populate the ARP table
#       2) It checks the Forward and Reverse DNS entries of the FQDNs and IPs according to a specific DNS server
#       3) It compares the IP/MAC mapping in the ARP table vs the expected ones in the provided CSV
#
#   Limitations:
#       * This script requires all devices in the list to be active on the network at the time of running for the MAC address resolution
#       * The host running the script (Kali) can't properly evaluate itself, says its own MAC is not live
#       * The host running the script needs layer 2 access to scan targets, so it won't work through firewalls.
#       * Sometimes different versions of Linux or commands will return MAC or Hostname results in different case formats (Hostname vs hostname) - this can cause some comparisons to fail.
#
#   Misc Notes:
#       This is a Linux script for a reason. Don't bother trying to do this on OS X, it's just a nightmare with the way OSX's version of the arp command inconsistently formats MAC addresses, and how it lacks the ip command by default.
#
#   Setup:
#       sudo apt-get update && sudo apt-get install -y wakeonlan

# immediately quit this script if any bomb out on errors
set -e

# define some variables
NETWORK_CIDR="10.0.1.0/24"                                      # for ping sweeping
DNS_SERVER_TO_TEST="10.0.1.11"                                  # IP for the DNS server that you want to test against
BROADCAST_IP_ADDRESS="10.0.1.255"
FILE_TO_VALIDATE="definitive-list-of-mac-ip-hostname.csv"       # file must exist - all contents must be lower case.
LIVE_ARP_TABLE="observed-mac-ip-hostname-list.csv"              # output file, will be overwritten if it exists
WAKE_LIST_FILE="wake_list.wol"

if [ ! -f "$FILE_TO_VALIDATE" ]; then
    echo "Validation file does not exist. Exiting."
    exit 2
fi

#####################################################################################
#	GLOBAL VARIABLES definitions (my comp-sci professors are rolling in their graves)
#####################################################################################

# global constants
# some of the formatting stuff screwed up the table
#GREEN=$(tput setaf 2)
#NORMAL=$(tput sgr0)
#CHECKMARK=$(printf "${GREEN}\xE2\x9C\x94${NORMAL}")
#CHECKMARK=$(printf "\xE2\x9C\x94")
CHECKMARK=$(printf "Y")
#FAILURE_X=$(printf "\xE2\x9D\x8C")
FAILURE_X=$(printf "N")
fmt='%-19s%-15s%-34s%-10s%-20s%-20s%-20s\n'


##############################################################################
#	FUNCTION DEFINITIONS
##############################################################################

is_valid_mac_address() {
    # determines if a string is a properly formatted MAC address
    if [[ "$1" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
        return 0
    else
        return 1
    fi
}

normalise_mac_address() {
    # formats MAC address into lower case with : - used for comparisons
    if is_valid_mac_address "$1" ; then
        echo "$1" | awk '{print tolower($0)}' | sed 's/\-/\:/g'
    else
        echo "Invalid MAC $1, can't normalize. Exiting."
        exit 4
    fi
}

compare_two_mac_adddresses() {
    # checks if two MAC addresses are equivalent. Makes sure they are both valid and then force them to lower case
     if [[ $(normalise_mac_address "$1") == $(normalise_mac_address "$2") ]]; then
        # MACs are equivalent, 0 is good in bash, means "true"
        return 0
    else
        #MACs are not equivalent
        return 1
    fi
}

compare_two_strings_return_check_or_x() {
    # case insensitive compare of two strings, returns a string used in the table
    shopt -s nocasematch; [[ "$1" == "$2" ]] && echo -n "$CHECKMARK" || echo -n "$FAILURE_X"
}

is_mac_live() {
    # determines if a MAC address was live in the local system's ARP cache at the time of scan.
    # this uses a static text file that stores the ARP table and doesn't reference it live
    # make sure the grep is case insensitive
    if grep -i -q "$1" "$LIVE_ARP_TABLE" ; then
        # in bash-land 0 is true/successful. uggh.
        #echo "MAC $1 is live"
        return 0
    else
        #echo "MAC $2 is NOT live"
        return 1
    fi
}

populate_arp_tables() {
    # scan the network to build up the local system's ARP table, ping only, without using reverse DNS lookups; ignore the output
    echo "Ping sweeping $NETWORK_CIDR to rebuild local ARP table..."
    
    nmap -sn --exclude 10.0.1.12 --max-retries 1 --initial-rtt-timeout 100ms --max-rtt-timeout 500ms --min-parallelism 10 --max-parallelism 50 "$NETWORK_CIDR"  > /dev/null
    
    # there's a 15 second delay in between when the nmap scan finishes while it shows a ton of non-live IPs in the ARP table
    #echo "Sleeping 20 sec to let the ARP table clean up..."
    #sleep 20

    echo "Gathering ARP table..."
    # removing the "incomplete" ARP entries to avoid having to wait 20+ seconds
    arp -d -a  | grep -v "incomplete" | awk '{print tolower($0)}' | awk '{gsub(/[()]/,""); print $4","$2","$1;}' | sort > "$LIVE_ARP_TABLE"

    if [ ! -f "$LIVE_ARP_TABLE" ]
    then
        echo "ARP file does not exist. Exiting."
        exit 1
    fi

    echo "ARP tables successfully populated."
}

clear_caches() {
    # clear the arp cache to avoid old cache problems, requires sudo priv; ignore output
    # this won't clear the local adapter's (like en0) entry from cache
    echo "Clearing ARP tables..."
    sudo ip -s -s neigh flush all   > /dev/null  # Linux
    echo "ARP tables successfully cleared."
}

check_host_output_line(){
    NORMALIZED_MAC=$(normalise_mac_address "$1")    # expected MAC address
    FULL_IP="$2"        # expected IP, not observed
    FQDN="$3"           # expected/authoritative FQDN, not observed
    
    SIMPLE_HOSTNAME=$(echo "$FQDN" | cut -d"." -f1) # simplify to just short hostname, remove domain

    if is_mac_live "$NORMALIZED_MAC"; then
        MAC_LIVE="Y"
        OBERVED_IP_FROM_MAC=$(grep -i "$NORMALIZED_MAC" "$LIVE_ARP_TABLE" | cut -d ',' -f2) # extract the observed IP address
        IP_MATCH_MAC=$(compare_two_strings_return_check_or_x "$OBERVED_IP_FROM_MAC" "$FULL_IP")
    else
        MAC_LIVE="N"
        IP_MATCH_MAC="not live"
    fi

    DNS_A_RECORD_RESPONSE=$(dig +short @$DNS_SERVER_TO_TEST "$FQDN" A)  # get raw response from DNS server about DNS Forward lookup for A record
    Fwd_DNS_MATCH_IP=$(compare_two_strings_return_check_or_x "$DNS_A_RECORD_RESPONSE" "$FULL_IP")   # return if they match or not.

    if dig +short -x "$FULL_IP" > /dev/null; then
        HOSTNAME_FROM_REVERSE_DNS=$(dig +short -x "$FULL_IP" | awk '{print tolower($0)}' | sed 's/\.$//g'  ) # returns a string with trailing period and mixed case, gotta remove that stuff
        # could be HOSTNAME without domain
        # could be multiple lines/entries
        Rev_DNS_MATCH_HOST=$(compare_two_strings_return_check_or_x "$HOSTNAME_FROM_REVERSE_DNS" "$FQDN")
    else
        Rev_DNS_MATCH_HOST="NR" # means no record was found on DNS server, couldn't compare
    fi
    
    # output everything in formatted line
    printf "$fmt" "$NORMALIZED_MAC" "$FULL_IP" "$SIMPLE_HOSTNAME" "$MAC_LIVE" "$Fwd_DNS_MATCH_IP" "$Rev_DNS_MATCH_HOST" "$IP_MATCH_MAC"
}

list_unreserved_live_dhcp_leases() { 
    echo "
    
======= Unreserved DHCP leases that are live ===========
    "
    # must use single quotes on regex, not double quotes
    grep -e '10\.0\.1\.[1-2][0-9][0-9]' "$LIVE_ARP_TABLE"
}

count_live_devices_sweep() {
    time nmap -sn --exclude 10.0.1.12 --max-retries 1 --initial-rtt-timeout 100ms --max-rtt-timeout 500ms --min-parallelism 10 --max-parallelism 50 "$NETWORK_CIDR"  > /dev/null
    # nmap with all the above flags took 8-12 seconds
    # nmap ping sweep without the extra flags took 8 seconds
    # nmap port scan without extra flags took
}

wake_any_non_live_mac_addresses() {
    # example file: /usr/share/doc/wakeonlan/examples/lab001.wol

    echo "Finding MAC addresses that aren't live."

    rm -f "$WAKE_LIST_FILE"     # remove the last temp file if it exists, don't throw error if it doesn't exist

    # make WOL file:
    while IFS="," read -r ITER_MAC_ADDRESS ITER_FULL_IP ITER_FQDN
    do
        NORMALIZED_MAC=$(normalise_mac_address "$ITER_MAC_ADDRESS")    # expected MAC address
        is_mac_live "$NORMALIZED_MAC" || echo "$ITER_MAC_ADDRESS $BROADCAST_IP_ADDRESS" >> "$WAKE_LIST_FILE"
    done < "$FILE_TO_VALIDATE"

    echo "Waking MAC addresses that did not seem to be live..."
    wakeonlan -f "$WAKE_LIST_FILE"
    sleep 20
    echo "Finished waiting for MACs to wake up."
}

##############################################################################
#	MAIN
##############################################################################

clear_caches
populate_arp_tables
wake_any_non_live_mac_addresses

# HEADERS - using underscores since Google Docs will split on spaces
printf "$fmt" "MAC" "IP" "HOSTNAME" "MAC_LIVE" "Fwd_DNS_MATCH_IP" "Rev_DNS_MATCH_HOST" "IP_MATCH_MAC"

# loop through each line of the file
while IFS="," read -r ITER_MAC_ADDRESS ITER_FULL_IP ITER_FQDN
do
    check_host_output_line "$ITER_MAC_ADDRESS" "$ITER_FULL_IP" "$ITER_FQDN"
done < "$FILE_TO_VALIDATE"

# TODO: use things like wdiff instead:
#diff "$FILE_TO_VALIDATE" "$LIVE_ARP_TABLE"

list_unreserved_live_dhcp_leases

echo "Script finished successfully."
