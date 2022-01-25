#!/bin/bash
# Tim H 2021

# looks up which Active Directory groups a list of AD users are in and compares them to a list that they should be in.
# used for new/recent hires to make sure they're in the right AD groups

# this is only good for Active Directory groups, doesn't work for Google Groups or any other type
# https://groups.google.com/my-groups?hl=en

LIST_OF_MY_EMPLOYEES_USERNAMES="username1 username2 username3"
GROUPS_MY_EMPLOYEES_SHOULD_BE_IN="$HOME/tmp/active_directory_groups_my_people_should_be_in.txt"
#MY_GROUPS_FILE="$HOME/tmp/authoritative_groups.txt"

#groups | tr " " "\n" | sort > "$MY_GROUPS_FILE"

for ITER_USERNAME in ${LIST_OF_MY_EMPLOYEES_USERNAMES}; do
    echo "============= $ITER_USERNAME ==================="
    groups "$ITER_USERNAME" | tr " " "\n" | sort > "groups_$ITER_USERNAME.txt"
    #diff "$MY_GROUPS_FILE" "groups_$ITER_USERNAME.txt"

    while read -r ITER_LINE; do
        #echo "$ITER_LINE"
        if ! grep -q -i "$ITER_LINE" "groups_$ITER_USERNAME.txt"; then
            echo "Please add $ITER_USERNAME to Active Directory group $ITER_LINE"
        fi
    done < "$GROUPS_MY_EMPLOYEES_SHOULD_BE_IN"
    echo ""
done
