FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-cli \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer \
    && wget -q "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" \
       -O /var/www/adminer/index.php

EXPOSE 8080

CMD ["php8.2", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer/"]
