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
# find . -type f -name '.DS_Store' -delete

# mark git hook scripts as executable
# find . -type f -path '*.git/hooks/*' ! -name '*.sample' -exec chmod u+x {} \+

# mark .sh files as executable
# the \+ is a lot faster than the \; in this situation
# find . -type f -name '*.sh' -exec chmod u+x {} \+


echo "Searching for git repositories..."
# next line is touchy, be cautious about making changes
find . -maxdepth 3 -mindepth 2 -type d -name '.git' -print0  | while read -r -d $'\0' ITER_PATH_TO_GIT_DIR
do
	# gotta have full path in here
	cd "$(dirname "${PATH_TO_REPOS}"/"${ITER_PATH_TO_GIT_DIR}")" || exit 2
	echo "${ITER_PATH_TO_GIT_DIR}"
	# git config core.fileMode true
	gh repo sync
	# git pull

	

	# # only do the status and push if it is one of my repos, skip if not
	# if [[ "${ITER_PATH_TO_GIT_DIR}" != *"third_party"* ]]; then
  	# 	git status #--ignored
	# 	git push
	# fi
	
done

echo "Script finished successfully."
