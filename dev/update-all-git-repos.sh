#!/bin/bash
# Tim H 2021
# READY_FOR_PUBLIC_REPO
# Goes through list of GitHub local folders and does a git pull on all of them

PATH_TO_REPOS="$HOME/source_code"

# skipping set -e since it'll bomb out if any one of the repos has a problem
# I'd rather it continue in the event of a problem
# set -e

# ensure that the source directory exists
if [ ! -d "$PATH_TO_REPOS" ]; then
    echo "Directory to repos does not exist: $PATH_TO_REPOS"
    exit 1
fi

cd "$PATH_TO_REPOS" || exit 3

# delete thumbnails
find . ! -path '*.git*' ! -path '*.venv*' ! -path '*third_party*' ! -path '*__pycache__*' ! -path './dataiku/*' -type f -name '.DS_Store' -delete
# time find .  -type f -name '.DS_Store' -delete

# mark git hook scripts as executable
# find . -type f -path '*.git/hooks/*' ! -name '*.sample' -exec chmod u+x {} \+

# mark .sh files as executable
# the \+ is a lot faster than the \; in this situation
gfind . -type f ! -executable ! -path '*.venv*' \( -name '*.sh' -o -name '*.zsh' \) -exec chmod u+x {} \+

echo "Searching for git repositories..."
# next line is touchy, be cautious about making changes
find . -maxdepth 3 -mindepth 2 -type d -name '.git' -print0 | while read -r -d $'\0' ITER_PATH_TO_GIT_DIR
do
	# gotta have full path in here
	cd "$(dirname "${PATH_TO_REPOS}"/"${ITER_PATH_TO_GIT_DIR}")" || exit 2
	
	# only do the status and push if it is one of my repos, skip if not
	if [[ "${ITER_PATH_TO_GIT_DIR}" != *"third_party"* ]]; then
		echo -e "\n\n=== Syncing repo: $ITER_PATH_TO_GIT_DIR ===\n"
		# quietly sync, do not display anything if sync was successful
		if ! gh repo sync > /dev/null; then
			echo "Error syncing: ${ITER_PATH_TO_GIT_DIR}"
			git status # --ignored
		fi

		git stash list
	fi
done

echo "Script finished successfully."
