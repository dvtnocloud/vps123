FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl sudo netcat-openbsd git python3 python3-pip && \
    pip3 install websockify && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# noVNC
RUN git clone https://github.com/novnc/noVNC.git /novnc && \
    ln -s /novnc/vnc.html /novnc/index.html

# Start noVNC gateway (8006 → 8081)
RUN printf '#!/bin/sh\n\
echo "[+] Starting noVNC on :8081"\n\
websockify --web=/novnc 8081 localhost:8006 &\n' \
> /novnc-start.sh && chmod +x /novnc-start.sh

# Cloudflare Tunnel xuất link noVNC
RUN printf '#!/bin/sh\n\
echo "[+] Creating Cloudflare tunnel..."\n\
cloudflared tunnel --url http://localhost:8081 --no-autoupdate --protocol http2\n' \
> /tunnel.sh && chmod +x /tunnel.sh

# Keepalive để Railway không kill container
RUN printf '#!/bin/sh\n\
while true; do echo "Windows + noVNC đang chạy..." | nc -l -p 8080; done\n' \
> /alive.sh && chmod +x /alive.sh

# Cấu hình Windows
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="4"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8081
EXPOSE 8006

# Không override ENTRYPOINT → để Windows tự boot
ENTRYPOINT ["/usr/bin/tini","--"]

# Chạy noVNC + tunnel + keepalive
CMD sh /novnc-start.sh & sh /alive.sh & sh /tunnel.sh
