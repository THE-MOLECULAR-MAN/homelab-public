#!/bin/bash
# Tim H 2020
# READY_FOR_PUBLIC_REPO
#
# Look for files that don't start with my standard header
# References:
#   https://stackoverflow.com/questions/32408820/how-to-list-files-and-match-first-line-in-bash-script
#   https://unix.stackexchange.com/questions/29878/can-i-access-nth-line-number-of-standard-output

# list .sh files in this repo that don't start with #!/bin/bash as the first line
find .. -not -path "*third-party*" -type f -name '*.sh' -print0 | while IFS= read -r -d $'\0' file; do
    if [[ $(head -n1 "$file") != "#!/bin/bash" ]]; then
        echo "First line was not #!/bin/bash: $file"
        # head -n2 "$file"
    fi

    if sed -n '2 p' "$file" | grep -qve "^\# Tim H" ; then
        echo "Second line of $file is not correct"
        # head -n2 "$file"
    fi
done
