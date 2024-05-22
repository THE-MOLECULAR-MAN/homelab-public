#!/bin/bash
# Tim H 2021-2024
# Search my source code repos for something

# for some reason (GDrive mounting or symlink?) have to cd
#    there first, can't just search directly

cd "$HOME/source_code" || exit 1 

find . -type f \
    \( -name '*.sh' -o -name '*.py' -o -name '*.ipynb' \) \
    -not -path '*.venv*' -not -path '*third_party*' \
    -exec grep -i --color=always --with-filename "$1" {} \+ | grep -v 'image/png' | cut -c1-200

# for troubleshooting:
    # -exec grep -i --files-with-matches "$1" {} \+
