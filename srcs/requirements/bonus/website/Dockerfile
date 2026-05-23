FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Remove default nginx site
RUN rm /etc/nginx/sites-enabled/default

COPY conf/nginx.conf /etc/nginx/sites-enabled/website.conf
COPY html/ /var/www/website/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
