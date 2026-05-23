FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Cria o diretório para os certificados SSL
RUN mkdir -p /etc/nginx/ssl

# Copia a configuração diretamente para o local correto do NGINX
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Copia o script de inicialização
COPY tools/generate_ssl.sh /usr/local/bin/generate_ssl.sh
RUN chmod +x /usr/local/bin/generate_ssl.sh

EXPOSE 443

# O Entrypoint roda o script e assume o comando padrão
ENTRYPOINT ["/usr/local/bin/generate_ssl.sh"]

# Comando padrão que será passado para o final do script
CMD ["nginx", "-g", "daemon off;"]