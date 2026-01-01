# =========================================
# WINDOWS + CLOUDFARE TUNNEL (NO LOGIN)
# RAILWAY DEPLOY - FINAL STABLE
# =========================================
FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Cloudflare tunnel script
RUN printf '#!/bin/bash\n\
echo "[+] Tạo link Cloudflare..."\n\
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 &\n' \
> /run-tunnel.sh && chmod +x /run-tunnel.sh

# Keepalive cho Railway (port 8080)
RUN printf '#!/bin/bash\n\
while true; do echo "<h1>Windows đang chạy trên Railway...</h1>" | nc -l -p 8080; done\n' \
> /keepalive.sh && chmod +x /keepalive.sh

# Config VM
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="2"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

# 🚀 Lệnh boot CHUẨN
ENTRYPOINT ["/usr/bin/tini","--"]
CMD /run-tunnel.sh & /keepalive.sh & exec /entry.sh
