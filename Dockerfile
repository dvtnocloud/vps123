FROM dockurr/windows:latest
USER root

# Cloudflare binary
RUN curl -L -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# noVNC web
RUN curl -L -o /tmp/novnc.tar.gz \
    https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz && \
    tar -xzf /tmp/novnc.tar.gz -C / && mv /noVNC-master /novnc && \
    ln -s /novnc/vnc.html /novnc/index.html

# websocat (không cần python)
RUN curl -L -o /usr/local/bin/websocat \
    https://github.com/vi/websocat/releases/latest/download/websocat_x86_64-linux && \
    chmod +x /usr/local/bin/websocat

# Start noVNC (chờ VNC Windows lên mới chạy)
RUN echo '#!/bin/sh' > /novnc.sh && \
    echo 'echo "[..] Waiting for Windows VNC on port 8006..."' >> /novnc.sh && \
    echo 'while ! nc -z localhost 8006; do sleep 1; done' >> /novnc.sh && \
    echo 'echo "[OK] VNC ready -> starting noVNC WebSocket at :8081"' >> /novnc.sh && \
    echo 'websocat -b ws-l:0.0.0.0:8081 tcp:localhost:8006 &' >> /novnc.sh && \
    chmod +x /novnc.sh

# Cloudflare Tunnel
RUN echo '#!/bin/sh' > /tunnel.sh && \
    echo 'cloudflared tunnel --url http://localhost:8081' >> /tunnel.sh && \
    chmod +x /tunnel.sh

# Keepalive cho Railway
RUN echo '#!/bin/sh' > /alive.sh && \
    echo 'while true; do echo alive | nc -l -p 8080; done' >> /alive.sh && chmod +x /alive.sh

EXPOSE 8080 8081 8006

ENTRYPOINT ["/usr/bin/tini","--"]
CMD sh /novnc.sh & sh /alive.sh & sh /tunnel.sh
