#!/bin/bash
# Tim H 2022
# Manually uninstalls nxlog
# Works on Ubuntu 20.04 VM and container

sudo rm -Rf \
    /etc/nxlog \
    /run/nxlog \
    /usr/local/share/doc/nxlog-ce \
    /usr/local/libexec/nxlog \
    /usr/local/bin/nxlog-processor \
    /usr/local/bin/nxlog-stmnt-verifier \
    /usr/local/bin/nxlog \
    /usr/local/etc/nxlog \
    /usr/local/share/nxlog-ce \
    /var/lib/dpkg/info/nxlog-ce.* \
    /var/log/nxlog \
    /var/run/nxlog \
    "$HOME/contrib"

find / -iname '*nxlog*' 2>/dev/null
