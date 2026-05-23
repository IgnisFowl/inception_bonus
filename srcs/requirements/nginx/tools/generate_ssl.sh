#!/bin/bash
set -e

# Garante que o diretório configurado no nginx.conf existe
mkdir -p /etc/ssl/nginx

# Gera o certificado autoassinado se ele ainda não existir
if [ ! -f /etc/ssl/nginx/nginx.crt ]; then
    echo "[nginx_init] Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/nginx/nginx.key \
        -out /etc/ssl/nginx/nginx.crt \
        -subj "/C=BR/ST=SP/L=SaoPaulo/O=42/CN=aarie-c2.42.fr"
    
    chmod 600 /etc/ssl/nginx/nginx.key
    chmod 644 /etc/ssl/nginx/nginx.crt
    echo "[nginx_init] SSL certificate generated successfully."
fi

# Passa o comando para o CMD (que é o 'nginx -g "daemon off;"') assumir como PID 1
exec "$@"