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
# Build the list of shell files git ITSELF records as non-executable (index mode
# 100644). Git tracks the executable bit, so "helpfully" chmod +x'ing one of these
# is a real content change: it leaves the repo permanently dirty and can block the
# fast-forward merges below on the next run. Verified live 2026-09-02:
# ai-studio's tools/fullperson_run_render_on_host.sh is tracked 100644.
GIT_NONEXEC_LIST="$(mktemp -t nonexec)"
trap 'rm -f "$GIT_NONEXEC_LIST"' EXIT
while IFS= read -r -d '' ITER_GIT_DIR
do
	ITER_REPO_DIR="$(dirname "$ITER_GIT_DIR")"
	( cd "$ITER_REPO_DIR" 2>/dev/null || exit 0
	  git ls-files -s -- '*.sh' '*.zsh' 2>/dev/null \
	    | awk -v r="$ITER_REPO_DIR" '$1=="100644"{sub(/^[^\t]*\t/,""); print r"/"$0}' )
done < <(find . -maxdepth 4 -mindepth 2 -type d -name '.git' ! -path './third_party/*' ! -path './dataiku_repos/*' -print0) >> "$GIT_NONEXEC_LIST"

echo "Marking .sh and .zsh files as executable (skipping $(wc -l < "$GIT_NONEXEC_LIST" | tr -d ' ') git-tracked non-executable file(s))..."
gfind . -type f \
	! -executable \
	! -path '*.venv*' \
	! -path '*.git*' \
	! -path '*.claude*' \
	! -path '*third_party*' \
	! -path './dataiku_repos/*' \
	! -path '*.vscode*' \
	! -path '*.ruff_cache*' \
	\( -name '*.sh' -o -name '*.zsh' \) -print \
	| grep -vxF -f "$GIT_NONEXEC_LIST" \
	| while IFS= read -r ITER_SH_FILE; do chmod u+x "$ITER_SH_FILE" && echo "$ITER_SH_FILE"; done

echo "Searching for git repositories..."
# next line is touchy, be cautious about making changes
find . -maxdepth 4 -mindepth 2 -type d -name '.git' ! -path './third_party/*' ! -path './dataiku_repos/*' -print0 | while read -r -d $'\0' ITER_PATH_TO_GIT_DIR
do
	# gotta have full path in here
	# `continue`, never `exit`: this while-loop runs in a subshell (it is on the
	# right of a pipe), so `exit` would kill the loop and SILENTLY SKIP EVERY
	# REMAINING REPO while the script still printed "finished successfully" --
	# the opposite of this script's own stated intent above.
	cd "$(dirname "${PATH_TO_REPOS}"/"${ITER_PATH_TO_GIT_DIR}")" || { echo "Could not cd into ${ITER_PATH_TO_GIT_DIR}, skipping"; continue; }

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
	# `sed -E 's/^[*+] /  /'` -- git marks the CURRENT branch with '*' but a branch
	# checked out in a WORKTREE with '+'. The old pattern stripped only '*', so for
	# every worktree branch awk took '+' as the branch name and the loop ran
	# `git branch -d +`. ai-studio has many worktrees; this fired constantly.
	#
	# Squash-merge note: when a PR is squash-merged (ai-studio merges every PR that
	# way) the local branch is NOT an ancestor of main, so `git branch -d` correctly
	# refuses it. That is git being right -- but a four-line warning per branch buries
	# everything else. ai-studio had 124 such branches on 2026-09-02, so the refusals
	# are summarised instead of printed one by one. Nothing is auto-force-deleted.
	ITER_KEPT_COUNT=0
	while read -r ITER_GONE_BRANCH
	do
		[ -z "$ITER_GONE_BRANCH" ] && continue
		if git branch -d "$ITER_GONE_BRANCH" > /dev/null 2>&1; then
			echo "Deleted local branch (remote branch was deleted): ${ITER_GONE_BRANCH}"
		else
			ITER_KEPT_COUNT=$((ITER_KEPT_COUNT + 1))
		fi
	done < <(git branch -vv | sed -E 's/^[*+] /  /' | awk '/: gone]/{print $1}')
	if [ "$ITER_KEPT_COUNT" -gt 0 ]; then
		echo "Kept ${ITER_KEPT_COUNT} local branch(es) whose remote is gone but which git will not fast-delete."
		echo "  Normal after a squash-merge. List: git branch -vv | grep ': gone]'"
		echo "  Delete one deliberately with: git branch -D <name>"
	fi

	git branch -vv | grep -v '\[.*\]'
	git stash list

done

echo "Script finished successfully."
