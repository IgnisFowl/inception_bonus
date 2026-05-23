FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp_setup.sh /usr/local/bin/ftp_setup.sh
RUN chmod +x /usr/local/bin/ftp_setup.sh

EXPOSE 21
EXPOSE 21000-21010

ENTRYPOINT ["/usr/local/bin/ftp_setup.sh"]
CMD ["vsftpd", "/etc/vsftpd.conf"]
