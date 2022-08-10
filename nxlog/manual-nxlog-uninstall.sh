
sudo rm -Rf /usr/local/share/doc/nxlog-ce \
    /usr/local/libexec/nxlog \
    /usr/local/bin/nxlog-processor \
    /usr/local/bin/nxlog-stmnt-verifier \
    /run/nxlog \
    /usr/local/bin/nxlog \
    /usr/local/share/nxlog-ce \
    /var/run/nxlog \
    /var/log/nxlog \
    /etc/nxlog

find / -iname '*nxlog*' 2>/dev/null

