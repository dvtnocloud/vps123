FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Cloudflare tunnel (show link)
RUN printf '#!/bin/sh\n\
echo "[+} Cloudflare Tunnel starting..."\n\
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 &\n\
' > /tunnel.sh && chmod +x /tunnel.sh

# Keep Railway alive on port 8080
RUN printf '#!/bin/sh\n\
while true; do echo \"Windows đang chạy trên Railway\" | nc -l -p 8080; done\n' \
> /alive.sh && chmod +x /alive.sh

# cấu hình Windows
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="4"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8006

# ❗Không override ENTRYPOINT nữa → Windows tự boot
ENTRYPOINT ["/usr/bin/tini","--"]

# ❗Không gọi /run.sh nữa → vì nó không tồn tại
CMD sh /tunnel.sh & sh /alive.sh & tail -f /dev/null
