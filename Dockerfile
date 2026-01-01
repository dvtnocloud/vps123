FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Cloudflare Tunnel
RUN printf '#!/bin/sh\n\
echo "[+] Cloudflare Tunnel Starting..."\n\
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 &\n\
' > /tunnel.sh && chmod +x /tunnel.sh

# Keepalive Web Port 8080
RUN printf '#!/bin/sh\n\
while true; do echo "Railway Alive" | nc -l -p 8080; done\n' \
> /alive.sh && chmod +x /alive.sh

# cấu hình Windows VM
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="4"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

# 🚀 ĐÂY LÀ DÒNG QUAN TRỌNG NHẤT (FIX TINI)
ENTRYPOINT ["/usr/bin/tini","--"]

# 🚀 BOOT CHUẨN (không còn lỗi -c)
CMD ["sh","-c","sh /tunnel.sh & sh /alive.sh & /run.sh"]
