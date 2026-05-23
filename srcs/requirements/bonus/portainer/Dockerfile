FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download Portainer CE binary (latest stable release)
RUN curl -fsSL \
    "https://github.com/portainer/portainer/releases/download/2.21.4/portainer-2.21.4-linux-amd64.tar.gz" \
    | tar -xz -C /

EXPOSE 9000

CMD ["/portainer/portainer", "--data", "/data"]
