# =========================================
# WINDOWS + CLOUDFLARE TUNNEL (NO LOGIN)
# RAILWAY DEPLOY 1 FILE 
# =========================================
FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
        -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Cloudflare Tunnel script
RUN echo '#!/bin/bash
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 2>&1 | grep -Eo "https://[a-zA-Z0-9.-]*\.trycloudflare\.com"
' > /run-tunnel.sh && chmod +x /run-tunnel.sh

# Railway keepalive web server (port 8080)
RUN echo '#!/bin/bash
while true; do echo "<h1>Windows đang chạy trên Railway...</h1>" | nc -l -p 8080; done
' > /keepalive.sh && chmod +x /keepalive.sh

# Windows VM config
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="2"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

# Quan trọng: KHÔNG DÙNG /init, dùng /usr/local/bin/launch
ENTRYPOINT ["/usr/bin/tini","--"]
CMD bash -c "/run-tunnel.sh & /keepalive.sh & exec /usr/local/bin/launch"
