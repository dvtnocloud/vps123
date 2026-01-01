# =========================================
# WINDOWS + CLOUDFLARE (NO LOGIN)
# RAILWAY - FINAL WORKING VERSION
# =========================================
FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Tạo tunnel + hiện link
RUN printf '#!/bin/sh\n\
echo "[+] Tạo Cloudflare Tunnel..."\n\
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 &\n\
' > /run-tunnel.sh && chmod +x /run-tunnel.sh

# Giữ Railway sống bằng port 8080
RUN printf '#!/bin/sh\n\
while true; do echo "Windows đang chạy trên Railway" | nc -l -p 8080; done\n' \
> /keepalive.sh && chmod +x /keepalive.sh

# Config Windows
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="2"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

# ⚠️ Không thay đổi ENTRYPOINT của image
# 🚀 Chỉ chạy phụ trợ rồi trả quyền boot về cho image
CMD sh /run-tunnel.sh & sh /keepalive.sh & tail -f /dev/null
