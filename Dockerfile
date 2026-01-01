FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Tunnel script
RUN printf '#!/bin/sh\n\
echo "[+] Đang tạo Cloudflare Tunnel..."\n\
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 &\n' \
> /run-tunnel.sh && chmod +x /run-tunnel.sh

# Keepalive trên port Railway
RUN printf '#!/bin/sh\n\
while true; do echo "Windows Railway Alive" | nc -l -p 8080; done\n' \
> /keepalive.sh && chmod +x /keepalive.sh

# Cấu hình cơ bản
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="2"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

# 🚀 CHỈ CÓ CMD, KHÔNG ENTRYPOINT
CMD sh /run-tunnel.sh & sh /keepalive.sh & tail -f /dev/null
