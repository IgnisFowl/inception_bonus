# USER_DOC.md — User Documentation

## What Services Are Provided?

The Inception stack exposes the following services:

| Service | URL / Address | Description |
|---------|--------------|-------------|
| WordPress site | `https://aarie-c2.42.fr` | Main website (accept self-signed cert) |
| WordPress admin | `https://aarie-c2.42.fr/wp-admin` | Administration dashboard |
| Adminer | `http://aarie-c2.42.fr:8080` | Database management UI |
| Portainer | `http://aarie-c2.42.fr:9000` | Container management dashboard |
| Static website | `http://aarie-c2.42.fr:80` | Portfolio/showcase site |
| FTP | `ftp://aarie-c2.42.fr:21` | File access to WordPress volume |

---

## Starting and Stopping the Project

```bash
# Start all services (build images if needed)
make

# Stop all running containers (data is preserved)
make down

# View live logs from all services
make logs

# Check container status
make status
```

---

## Accessing the Website

1. Make sure `aarie-c2.42.fr` is in your `/etc/hosts`:
   ```
   127.0.0.1  aarie-c2.42.fr
   ```
2. Open your browser and visit `https://aarie-c2.42.fr`
3. Accept the self-signed TLS certificate warning

### WordPress Admin Panel
- URL: `https://aarie-c2.42.fr/wp-admin`
- Admin username: see `secrets/credentials.txt` → `ADMIN_PASSWORD`
- Admin login: `aarie_chief` (defined in `srcs/.env`)

---

## Locating and Managing Credentials

All credentials are stored in the `secrets/` directory at the root of the repository. **These files must never be committed to Git.**

| File | Contents |
|------|----------|
| `secrets/db_password.txt` | MariaDB `wp_user` password |
| `secrets/db_root_password.txt` | MariaDB `root` password |
| `secrets/credentials.txt` | WordPress admin + user + FTP passwords |

To change a password:
1. Edit the corresponding file in `secrets/`
2. Run `make fclean && make` to rebuild with the new secret

---

## Checking That Services Are Running

```bash
# Quick status of all containers
make status

# Check a specific container's logs
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis
docker logs ftp
docker logs adminer
docker logs portainer
docker logs website

# Verify MariaDB is responding
docker exec mariadb mysqladmin ping -u root -p

# Verify WordPress is serving
curl -k https://aarie-c2.42.fr | head -20
```

---

## Stopping and Cleaning Up

```bash
# Stop without data loss
make down

# Stop + remove volumes (DATA WILL BE LOST)
make clean

# Full reset: remove containers, volumes, and images
make fclean
```
