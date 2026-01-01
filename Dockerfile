FROM dockurr/windows:latest
USER root

# Cài package đúng cho Alpine
RUN apk update && \
    apk add --no-cache curl git python3 py3-pip netcat-openbsd && \
    pip3 install websockify && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /novnc && \
    ln -s /novnc/vnc.html /novnc/index.html

# Start noVNC (VNC → WebSocket)
RUN echo '#!/bin/sh' > /novnc.sh && \
    echo 'echo "[OK] noVNC running at :8081"' >> /novnc.sh && \
    echo 'websockify --web=/novnc 8081 localhost:8006 &' >> /novnc.sh && \
    chmod +x /novnc.sh

# Cloudflare tunnel
RUN echo '#!/bin/sh' > /tunnel.sh && \
    echo 'echo "[OK] Creating Cloudflare Tunnel..."' >> /tunnel.sh && \
    echo 'cloudflared tunnel --url http://localhost:8081 --no-autoupdate --protocol http2' >> /tunnel.sh && \
    chmod +x /tunnel.sh

# Keepalive Railway
RUN echo '#!/bin/sh' > /alive.sh && \
    echo 'while true; do echo OK | nc -l -p 8080; done' >> /alive.sh && \
    chmod +x /alive.sh

# Windows config
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"
ENV VERSION="10"
ENV SCREEN_RESOLUTION="1280x720"

EXPOSE 8080
EXPOSE 8081
EXPOSE 8006

ENTRYPOINT ["/usr/bin/tini","--"]
CMD sh /novnc.sh & sh /alive.sh & sh /tunnel.sh
