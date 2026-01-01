FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl netcat-openbsd python3 python3-pip git && \
    pip3 install websockify && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# Tải noVNC (web VNC client)
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /novnc && \
    ln -s /novnc/vnc.html /novnc/index.html

# Start noVNC (Windows VNC port -> WebSocket)
RUN printf '#!/bin/sh\n\
echo "[+] noVNC running on 8081"\n\
websockify --web=/novnc 8081 localhost:8006 &\n\
' > /novnc.sh && chmod +x /novnc.sh

# Cloudflare Tunnel xuất link truy cập qua web
RUN printf '#!/bin/sh\n\
echo "[+] Creating Cloudflare tunnel..."\n\
cloudflared tunnel --url http://localhost:8081 --no-autoupdate --protocol http2\n' \
> /tunnel.sh && chmod +x /tunnel.sh

# Anti-idle để Railway không kill
RUN printf '#!/bin/sh\n\
while true; do echo "OK" | nc -l -p 8080; done\n' \
> /alive.sh && chmod +x /alive.sh

# Config Windows
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV RAM_SIZE="8G"
ENV CPU_CORES="4"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8081
EXPOSE 8006

ENTRYPOINT ["/usr/bin/tini","--"]
CMD sh /novnc.sh & sh /alive.sh & sh /tunnel.sh
