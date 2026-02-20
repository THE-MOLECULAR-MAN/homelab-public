#!/bin/bash
# Tim H 2021-2024
# Search my source code repos for something

# for some reason (GDrive mounting or symlink?) have to cd
#    there first, can't just search directly

cd "$HOME/source_code" || exit 1 

find . \
    -not -path '*.venv*' \
    -not -path '*third_party*' \
    -type f \
    \( -iname '*.sh' -o -iname '*.py' -o -iname '*.txt' -o -iname '*.ipynb' -o -iname '*.ps1' -o -iname '*.md' \) \
    -exec grep -i --color=always --with-filename "$1" {} \+ | grep -v 'image/png' | cut -c1-200

# for troubleshooting:
    # -exec grep -i --files-with-matches "$1" {} \+
