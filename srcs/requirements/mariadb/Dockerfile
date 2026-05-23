FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Pre-create runtime directories with correct ownership
RUN mkdir -p /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf
COPY tools/db_init.sh /usr/local/bin/db_init.sh
RUN chmod +x /usr/local/bin/db_init.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/db_init.sh"]
CMD ["mysqld", "--user=mysql"]
