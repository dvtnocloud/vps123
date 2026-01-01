# =========================================
# WINDOWS + CLOUDFLARE TUNNEL (NO LOGIN)
# RAILWAY FRIENDLY - SHOW LOGS
# =========================================
FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Tạo script start
RUN printf '#!/bin/bash\n\
echo "---------------------------------------"\n\
echo " 🚀 Khởi động Windows + Cloudflare Tunnel"\n\
echo "---------------------------------------"\n\
echo "[+] Đang tạo link cloudflare..."\n\
( cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 2>&1 | grep -Eo "https://[a-zA-Z0-9.-]*\\.trycloudflare\\.com" ) &\n\
echo "[+] Khởi động web keepalive Railway (port 8080)"\n\
( while true; do echo "<h1>Windows đang chạy trên Railway...</h1>" | nc -l -p 8080; done ) &\n\
echo "[+] Booting Windows VM..."\n\
exec /run\n' > /start.sh && chmod +x /start.sh

# Cấu hình Windows VM
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="2"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/start.sh"]
