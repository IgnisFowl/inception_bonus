#!/bin/bash
set -e

# ── Read secrets ─────────────────────────────────────────────────────────────
DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\n')
WP_ADMIN_PASSWORD=$(grep '^ADMIN_PASSWORD=' /run/secrets/credentials | cut -d= -f2 | tr -d '\n')
WP_USER_PASSWORD=$(grep  '^USER_PASSWORD='  /run/secrets/credentials | cut -d= -f2 | tr -d '\n')

WP_PATH=/var/www/html

# ── Wait for MariaDB ─────────────────────────────────────────────────────────
echo "[wp_setup] Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done
echo "[wp_setup] MariaDB is up."

# ── Bootstrap WordPress (only on first run) ──────────────────────────────────
if [ ! -f "${WP_PATH}/wp-config.php" ]; then

    wp core download \
        --path="${WP_PATH}" \
        --allow-root

    wp config create \
        --path="${WP_PATH}" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --path="${WP_PATH}" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        --path="${WP_PATH}" \
        "${WP_USER_LOGIN}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    # ── Redis cache ───────────────────────────────────────────────────────────
    wp plugin install redis-cache --activate --allow-root --path="${WP_PATH}"
    wp config set WP_REDIS_HOST redis   --allow-root --path="${WP_PATH}"
    wp config set WP_REDIS_PORT 6379    --allow-root --path="${WP_PATH}" --raw
    wp redis enable                     --allow-root --path="${WP_PATH}"

    chown -R www-data:www-data "${WP_PATH}"
fi

echo "[wp_setup] Starting php-fpm..."
exec /usr/sbin/php-fpm8.2 -F
