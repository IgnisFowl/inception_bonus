#!/bin/bash
set -e

# Extrai o usuário e senha (garantindo que lê os segredos do Docker)
FTP_USER=$(grep '^USER_LOGIN=' /run/secrets/credentials | cut -d= -f2 | tr -d '\n')
FTP_PASS=$(grep '^USER_PASSWORD=' /run/secrets/credentials | cut -d= -f2 | tr -d '\n')

# Cria o usuário no Linux se ele não existir, definindo a pasta do WP como HOME
if ! id "$FTP_USER" &>/dev/null; then
    echo "[ftp_setup] Creating FTP user: $FTP_USER"
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    # Vincula o usuário ao grupo www-data para evitar bugs de escrita no WordPress
    usermod -aG www-data "$FTP_USER"
fi

# ── FIX CRÍTICO: Configuração do diretório seguro exigido pelo vsftpd ──
# O vsftpd exige que este diretório exista, pertença ao root e seja estritamente read-only
mkdir -p /var/run/vsftpd/empty
chown -R root:root /var/run/vsftpd/empty
chmod 555 /var/run/vsftpd/empty

echo "[ftp_setup] Starting vsftpd..."

# Executa o comando principal (passado via CMD: vsftpd /etc/vsftpd.conf)
exec "$@"