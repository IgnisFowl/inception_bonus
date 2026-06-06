# Implementation Plan - Inception VM Setup & Verification

This detailed guide outlines how to build, configure, run, and verify the Inception project inside a Virtual Machine (VM), and how to export/import that VM for evaluation on 42 physical workstations.

---

## 1. Virtual Machine Selection & OS Installation
For a stable 42 Inception environment, the recommended configuration is:
- **Hypervisor**: VirtualBox (standard at 42) or UTM/VMware.
- **Base OS**: Ubuntu 24.04 LTS or Debian 12 (Bookworm).
- **Resources**: 2 CPUs, 2048 MB RAM, 20 GB dynamically allocated storage.
- **Network Mode**: Bridged Adapter or NAT with Port Forwarding (443, 80, 21, 8080, 8081, 9000).

---

## 2. Docker & Environment Setup (Step-by-Step Commands)

Execute these commands inside your VM to prepare the environment:

### Step A: Update Package Index and Install Prerequisites
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl gnupg ca-certificates lsb-release make git
```

### Step B: Install Official Docker Engine
To ensure we have Docker Engine ≥ 24 and Compose v2 (avoiding outdated distro packages):
```bash
# Add Docker's official GPG key:
sudo fold -s /etc/apt/keyrings || sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker components:
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step C: Configure User Permissions (Non-root Docker)
Adding the user to the `docker` group permits running compose commands without prefixing `sudo`:
```bash
sudo usermod -aG docker $USER
# Apply group changes immediately:
newgrp docker
```
*Verify with:* `docker run hello-world`

---

## 3. Storage & Domain Mapping (Specific to `aarie-c2`)

The peer repository is configured to use the user login `aarie-c2`. The evaluation checklist and subject state:
> *Verify that the standard output contains the path '/home/login/data/'*

We must create this exact path on the host system.

### Step A: Create Host Directories
Since the VM's login might be different (e.g. `aline-arthur`), we must create the directory structure at `/home/aarie-c2` using administrative privileges:
```bash
sudo mkdir -p /home/aarie-c2/data/mariadb
sudo mkdir -p /home/aarie-c2/data/wordpress
sudo mkdir -p /home/aarie-c2/data/portainer

# Change ownership to the active VM user (e.g. aline-arthur) so that Docker and make can read/write to it:
sudo chown -R $USER:$USER /home/aarie-c2
```

### Step B: DNS Local Mapping
The project demands the domain `login.42.fr` to point locally. Add it to `/etc/hosts`:
```bash
echo "127.0.0.1  aarie-c2.42.fr" | sudo tee -a /etc/hosts
```
*Verify with:* `ping -c 2 aarie-c2.42.fr` (should resolve to `127.0.0.1`).

---

## 4. Building and Deploying the Project

### Step A: secrets Files Setup
The project uses Docker secrets. Make sure the files exist and contain appropriate values:
```bash
cd /home/aline-arthur/Documents/42/inception/inception_bonus

# Ensure secrets directory exists
mkdir -p secrets

# Add dummy values if missing
echo "dbpass123" > secrets/db_password.txt
echo "dbrootpass123" > secrets/db_root_password.txt

cat > secrets/credentials.txt <<EOF
ADMIN_PASSWORD=AdminPasswordDoWP2026!
USER_LOGIN=editor_user
USER_PASSWORD=EditorPass123!
EOF
```

### Step B: Build Services
Run the Makefile to compile and start the containers:
```bash
make
```
*Wait 30-60 seconds for WordPress initialization script to run.*

---

## 5. Verification Plan

Check the following to ensure the VM is fully functional and ready for peer evaluation:

| Target | Command / Check | Expected Behavior |
|--------|-----------------|-------------------|
| **NGINX / SSL** | `curl -kIv https://aarie-c2.42.fr` | Returns HTTP 200, uses TLS 1.2 or 1.3, SSL certificate details shown. |
| **Port 80 Block** | `curl -I http://aarie-c2.42.fr` | Connection refused or timed out (must NOT serve HTTP). |
| **WordPress DB** | Log in at `https://aarie-c2.42.fr/wp-admin` | Admin dashboard loads. Admin user must NOT contain "admin". |
| **Redis Cache** | Check WP plugins or `docker logs redis` | Redis object cache plugin active and connected to `redis:6379`. |
| **FTP Access** | `ftp -p aarie-c2.42.fr` (Port 21) | Connection opens; allows listing `/var/www/html` files using secrets credentials. |
| **Showcase Page**| Access `http://aarie-c2.42.fr:8081` | Static portfolio website loads correctly. |
| **Adminer UI** | Access `http://aarie-c2.42.fr:8080` | DB login panel visible; connects to `mariadb` with DB credentials. |
| **Portainer** | Access `https://aarie-c2.42.fr:9000` | Portainer dashboard accessible. |
| **Data Persistence**| Run `make clean` then `make` | Changes to WordPress pages/comments remain intact. |

---

## 6. Exporting and Importing the Virtual Machine

Once the VM is fully configured and all services run correctly, package it for the 42 evaluation computer:

### Step A: Clean Cache and Temp Files
To keep the export file size minimal, run these commands inside the VM before exporting:
```bash
# Stop docker containers
make down

# Clean docker cache
docker system prune -af --volumes

# Clear apt cache
sudo apt-get clean
sudo apt-get autoremove -y

# Zero out free space (makes the VM image compress significantly better)
dd if=/dev/zero of=/var/tmp/bigemptyfile bs=4096k conv=fdatasync || true
rm /var/tmp/bigemptyfile
```

### Step B: Exporting from VirtualBox (on home PC)
1. Open VirtualBox.
2. Select your VM.
3. Click **File** > **Export Appliance...**
4. Choose **Format**: `Open Virtualization Format 2.0 (OVA)` or `1.0`.
5. Specify target file path (e.g. `Inception_aarie-c2.ova`).
6. Click **Export**. Copy this `.ova` file to a USB flash drive.

### Step C: Importing on 42 Workstation
1. Copy the `.ova` file from the USB flash drive to the 42 workstation.
2. Open VirtualBox on the 42 computer.
3. Click **File** > **Import Appliance...**
4. Select the `.ova` file and click **Import**.
5. Set network configuration to **Bridged** or **NAT** (matching the workstation's internet access).
6. Start the VM and perform evaluation checks.
