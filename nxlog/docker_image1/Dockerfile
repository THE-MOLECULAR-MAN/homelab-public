FROM nxlog/nxlog-ce
USER root
RUN chmod -R 755 /var/log/
RUN mkdir /plex_logs
RUN chmod 755 /plex_logs/
COPY nxlog.conf /etc/nxlog/
RUN chmod 755 /etc/nxlog/nxlog.conf
