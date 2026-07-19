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
find . ! -path '*.git*' ! -path '*.venv*' ! -path '*third_party*' ! -path '*__pycache__*' ! -path './dataiku_repos/*' -type f -name '.DS_Store' -delete
# time find .  -type f -name '.DS_Store' -delete

# mark git hook scripts as executable
# find . -type f -path '*.git/hooks/*' ! -name '*.sample' -exec chmod u+x {} \+

# mark .sh files as executable
# the \+ is a lot faster than the \; in this situation
echo "Marking .sh and .zsh files as executable..."
gfind . -type f \
	! -executable \
	! -path '*.venv*' \
	! -path '*.git*' \
	! -path '*.claude*' \
	! -path '*third_party*' \
	! -path './dataiku_repos/*' \
	! -path '*.vscode*' \
	! -path '*.ruff_cache*' \
	\( -name '*.sh' -o -name '*.zsh' \) -print -exec chmod u+x {} \+

echo "Searching for git repositories..."
# next line is touchy, be cautious about making changes
find . -maxdepth 4 -mindepth 2 -type d -name '.git' ! -path './third_party/*' ! -path './dataiku_repos/*' -print0 | while read -r -d $'\0' ITER_PATH_TO_GIT_DIR
do
	# gotta have full path in here
	cd "$(dirname "${PATH_TO_REPOS}"/"${ITER_PATH_TO_GIT_DIR}")" || exit 2

	echo -e "\n\n=== Syncing repo: $ITER_PATH_TO_GIT_DIR ===\n"

	# fetch all remotes/branches and prune remote-tracking refs that no longer exist
	if ! git fetch --all --prune --quiet; then
		echo "Error fetching: ${ITER_PATH_TO_GIT_DIR}"
		git status # --ignored
	fi

	CURRENT_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null)"

	# fast-forward every local branch that has a live upstream.
	# the currently checked-out branch is updated with a plain merge;
	# every other branch is updated via a direct fetch-into-ref so the
	# working tree is never switched away from CURRENT_BRANCH.
	while IFS=' ' read -r ITER_BRANCH ITER_REMOTE ITER_UPSTREAM
	do
		if [ -z "$ITER_UPSTREAM" ]; then
			continue
		fi
		# skip upstreams that no longer exist (remote branch was deleted);
		# those are handled by the "gone" cleanup step below
		if ! git rev-parse --verify -q "$ITER_UPSTREAM" > /dev/null; then
			continue
		fi

		if [ "$ITER_BRANCH" = "$CURRENT_BRANCH" ]; then
			if ! git merge --ff-only -q "$ITER_UPSTREAM"; then
				echo "Could not fast-forward ${ITER_BRANCH} from ${ITER_UPSTREAM} (local changes or diverged history)"
			fi
		else
			ITER_REMOTE_BRANCH="${ITER_UPSTREAM#"${ITER_REMOTE}"/}"
			if ! git fetch -q "$ITER_REMOTE" "${ITER_REMOTE_BRANCH}:${ITER_BRANCH}"; then
				echo "Could not fast-forward ${ITER_BRANCH} from ${ITER_UPSTREAM} (diverged history)"
			fi
		fi
	done < <(git for-each-ref --format='%(refname:short) %(upstream:remotename) %(upstream:short)' refs/heads/)

	# delete local branches whose upstream was deleted on the remote
	# (local-only branches with no upstream are left untouched).
	# uses a safe delete so branches with unmerged local commits are kept.
	git branch -vv | sed 's/^\* /  /' | awk '/: gone]/{print $1}' | while read -r ITER_GONE_BRANCH
	do
		if git branch -d "$ITER_GONE_BRANCH" 2> /dev/null; then
			echo "Deleted local branch (remote branch was deleted): ${ITER_GONE_BRANCH}"
		else
			echo "Skipped deleting ${ITER_GONE_BRANCH}: has commits not merged upstream (remote branch was deleted). Remove manually with 'git branch -D ${ITER_GONE_BRANCH}' if intended."
		fi
	done

	git stash list

done

echo "Script finished successfully."
