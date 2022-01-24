#!/bin/bash
# Tim H 2021
#
# Test Ansible YML files

# bail immediately on any failures
set +e

# check static config file first, don't want to run it as playbook
yamllint requirements.yml

# Read the array values with space
for ITER_PLAYBOOK_FILENAME in playbook-*.yml; do
    yamllint "$ITER_PLAYBOOK_FILENAME"
    # ansible-lint "$ITER_PLAYBOOK_FILENAME"    # broken for now
    set -e
    ansible-playbook --syntax-check "$ITER_PLAYBOOK_FILENAME" -i /etc/ansible/hosts
    set +e
done
