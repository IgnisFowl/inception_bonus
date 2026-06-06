#!/bin/bash
# Opcional: mude para 'set -ex' se ainda quiser ver o rastro de cada linha nos logs
set -e

# ── Carregar as senhas de forma segura via Docker Secrets ────────────────────
DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\n')
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password | tr -d '\n')

# ── Garantir as pastas de execução e permissões corretas do Linux ────────────
mkdir -p /run/mysqld /var/log/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

# ── Inicialização Primária do Banco de Dados ─────────────────────────────────
# Mudamos a checagem para procurar pela pasta do SEU banco de dados
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "[db_init] Banco de dados '${MYSQL_DATABASE}' não encontrado. Inicializando..."

    # 1. Cria a estrutura base do sistema de arquivos do MariaDB
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    echo "[db_init] Executando comandos de privilégios, usuários e tabelas via bootstrap..."
    
    # 2. O `--bootstrap` lê os comandos SQL via stdin, processa internamente e fecha de forma síncrona
    mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "[db_init] Configuração inicial concluída com sucesso."
fi

# ── Inicialização de Produção ────────────────────────────────────────────────
echo "[db_init] Passando controle para o processo principal (mysqld)..."
exec "$@"