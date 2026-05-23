#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\n')
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password | tr -d '\n')

# ── Ensure runtime directories exist with correct ownership ──────────────────
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# ── First-time initialization ────────────────────────────────────────────────
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[db_init] Initializing MariaDB data directory..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    # Start a temporary mysqld (no networking) to run setup SQL
    mysqld --user=mysql --skip-networking &
    MYSQL_PID=$!

    # Wait until mysqld is accepting connections
    echo "[db_init] Waiting for temporary mysqld..."
    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    # Bootstrap: root password, database, user
    mysql -u root <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "[db_init] Shutting down temporary mysqld..."
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait $MYSQL_PID

    echo "[db_init] Database initialized successfully."
fi

echo "[db_init] Starting mysqld..."
exec "$@"
