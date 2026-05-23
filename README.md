*This project has been created as part of the 42 curriculum by aarie-c2.*

---

# Inception

## Description

**Inception** is a system administration project that builds a small but complete web infrastructure entirely with Docker. Every service runs in its own dedicated container, built from scratch from a `debian:bookworm` base image — no pre-made images from DockerHub.

The stack delivers a fully functional WordPress site with:
- **NGINX** as the sole HTTPS entry point (TLSv1.2 / TLSv1.3)
- **WordPress + php-fpm** for the CMS
- **MariaDB** for the relational database
- **Redis** for object caching
- **vsftpd** for FTP access to the WordPress volume
- **A static portfolio website** (this repo's showcase page)
- **Adminer** for database management
- **Portainer CE** for container management

### Key Design Choices

#### Virtual Machines vs Docker
| | Virtual Machine | Docker Container |
|-|-----------------|-----------------|
| Isolation | Full OS-level | Process-level (namespaces + cgroups) |
| Startup | Minutes | Seconds |
| Overhead | High (full kernel) | Low (shared host kernel) |
| Use case | Full OS isolation, legacy apps | Lightweight, reproducible services |

Docker containers share the host kernel, making them lighter and faster than VMs. They are not VMs — they don't boot a full OS.

#### Secrets vs Environment Variables
| | Secrets | Environment Variables |
|-|---------|----------------------|
| Storage | Files mounted at `/run/secrets/` | Process environment |
| Visibility | Available only inside the container | Visible in `docker inspect` |
| Use case | Passwords, API keys | Config values (domain, usernames) |

Passwords are stored in `secrets/` files and mounted as Docker secrets. Non-sensitive configuration (domain name, usernames) lives in `.env`.

#### Docker Network vs Host Network
| | Docker Bridge Network | Host Network |
|-|-----------------------|-------------|
| Isolation | Containers on a private subnet | Container shares host network |
| Security | Services unreachable from outside unless port-mapped | All container ports exposed on host |
| DNS | Containers resolve each other by service name | Must use host IPs |

This project uses a custom **bridge network** (`inception_net`). Containers communicate by service name (e.g., `wordpress:9000`, `mariadb:3306`). Only required ports are published to the host.

#### Docker Volumes vs Bind Mounts
| | Named Volume (with bind mount) | Anonymous Volume |
|-|-------------------------------|-----------------|
| Location | Explicit host path | Docker-managed path |
| Persistence | Survives `docker compose down` | May be removed |
| Inspectability | Easy to navigate on host | Hidden inside Docker data dir |

Volumes are configured with `driver_opts: type: none, o: bind` to pin data at `/home/aarie-c2/data/{db,wordpress}`.

---

## Instructions

### Prerequisites
- Docker Engine ≥ 24
- Docker Compose v2
- `make`
- Add to `/etc/hosts`: `127.0.0.1  aarie-c2.42.fr`
- Create the data directory: `sudo mkdir -p /home/aarie-c2/data`

### Run

```bash
# Clone and enter the repository
git clone <repo-url> inception && cd inception

# Build and start all containers
make

# Stop without removing data
make down

# Full teardown (removes containers, volumes, images)
make fclean
```

---

## Resources

### Documentation
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX docs](https://nginx.org/en/docs/)
- [WordPress CLI (wp-cli)](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Redis docs](https://redis.io/docs/)
- [vsftpd manual](https://security.appspot.com/vsftpd.html)
- [Portainer docs](https://docs.portainer.io/)

### AI Usage
AI (Antigravity / Claude) was used for the following tasks:
- **Scaffolding**: generating the initial directory structure and boilerplate Dockerfiles
- **Configuration**: drafting nginx.conf, vsftpd.conf, php-fpm pool, MariaDB config
- **Entrypoint scripts**: structuring the init logic for MariaDB bootstrap and WordPress WP-CLI automation
- **Documentation**: drafting README.md, USER_DOC.md, DEV_DOC.md structure

All AI-generated content was reviewed, tested, and adjusted. I take full responsibility for every line in this repository.
