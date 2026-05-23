# DEV_DOC.md — Developer Documentation

## Prerequisites

Install the following on your system (or inside your VM):

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y docker.io docker-compose-v2 make git

# Add your user to the docker group (avoids sudo for docker commands)
sudo usermod -aG docker $USER
newgrp docker
```

Also add the domain to `/etc/hosts`:
```bash
echo "127.0.0.1  aarie-c2.42.fr" | sudo tee -a /etc/hosts
```

---

## Setting Up From Scratch

### 1. Clone the repository

```bash
git clone <repo-url> inception
cd inception
```

### 2. Create the secrets files

The `secrets/` directory is gitignored. You must create these files manually:

```bash
# MariaDB user password
echo "YourStrongPassword1" > secrets/db_password.txt

# MariaDB root password
echo "YourStrongRootPassword1" > secrets/db_root_password.txt

# WordPress admin, regular user, and FTP passwords
cat > secrets/credentials.txt <<EOF
ADMIN_PASSWORD=YourAdminPass1
USER_PASSWORD=YourUserPass1
FTP_PASSWORD=YourFtpPass1
EOF
```

> ⚠️ Never commit these files. They are in `.gitignore`.

### 3. Review the environment file

Non-sensitive configuration is in `srcs/.env`:

```dotenv
DOMAIN_NAME=aarie-c2.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
WP_ADMIN_USER=aarie_chief
WP_ADMIN_EMAIL=admin@aarie-c2.42.fr
WP_USER=aarie_c2
WP_USER_EMAIL=user@aarie-c2.42.fr
WP_TITLE=Inception by aarie-c2
FTP_USER=ftpuser
```

### 4. Create the host data directories

The Makefile does this automatically, but you can do it manually:

```bash
sudo mkdir -p /home/aarie-c2/data/db
sudo mkdir -p /home/aarie-c2/data/wordpress
```

---

## Build and Launch

```bash
# Build all images and start all containers in detached mode
make

# Equivalent manual command
docker compose -f srcs/docker-compose.yml up -d --build
```

On first boot, the WordPress setup script will:
1. Wait for MariaDB to be ready
2. Download WordPress core
3. Configure `wp-config.php`
4. Install WordPress with admin credentials
5. Create the second (author) user
6. Install and enable the Redis Object Cache plugin

This takes ~30–60 seconds on first run.

---

## Useful Container Management Commands

```bash
# Follow logs for all services
make logs

# Follow logs for a single service
docker logs -f wordpress

# Open an interactive shell in a container
docker exec -it wordpress bash
docker exec -it mariadb bash

# Run a WP-CLI command inside the WordPress container
docker exec wordpress wp plugin list --allow-root

# Check MariaDB from inside the container
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Inspect the bridge network
docker network inspect srcs_inception_net

# List all images built for this project
docker images | grep -E "nginx|wordpress|mariadb|redis|ftp|website|adminer|portainer"
```

---

## Project Data Location

All persistent data is stored on the **host** filesystem:

| Data | Host path | Volume name |
|------|-----------|-------------|
| MariaDB database files | `/home/aarie-c2/data/db` | `wordpress_db` |
| WordPress site files | `/home/aarie-c2/data/wordpress` | `wordpress_files` |

Data **survives** `make down` (stop only).  
Data is **removed** by `make clean` or `make fclean`.

---

## Project Structure

```
inception/
├── Makefile                        # Build orchestration
├── README.md                       # Project overview
├── USER_DOC.md                     # End-user documentation
├── DEV_DOC.md                      # This file
├── .gitignore                      # Ignores secrets/ and .env
├── secrets/                        # Secret files (gitignored)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── .env                        # Non-sensitive env vars
    ├── docker-compose.yml          # Service definitions
    └── requirements/
        ├── nginx/                  # NGINX (TLS termination)
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/generate_ssl.sh
        ├── wordpress/              # WordPress + php-fpm
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/wp_setup.sh
        ├── mariadb/                # MariaDB
        │   ├── Dockerfile
        │   ├── conf/my.cnf
        │   └── tools/db_init.sh
        └── bonus/
            ├── redis/              # Redis cache
            ├── ftp/                # FTP server (vsftpd)
            ├── website/            # Static portfolio site
            ├── adminer/            # DB admin UI
            └── portainer/          # Container dashboard
```

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|-------------|-----|
| `https://aarie-c2.42.fr` unreachable | `/etc/hosts` entry missing | `echo "127.0.0.1 aarie-c2.42.fr" \| sudo tee -a /etc/hosts` |
| WordPress shows DB connection error | MariaDB not ready yet | Wait ~30s and refresh, or `docker logs wordpress` |
| Port 443 already in use | Another service using port 443 | `sudo lsof -i :443` and stop conflicting process |
| `make clean` fails on volumes | Volumes in use | Run `make down` first, then `make clean` |
| FTP passive connection fails | Wrong `pasv_address` | Edit `vsftpd.conf`: set `pasv_address` to host IP |
