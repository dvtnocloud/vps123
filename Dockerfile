FROM dockurr/windows:latest
USER root

# Cloudflare Binary
RUN curl -L -o /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# Download noVNC (tar.gz, giải nén bằng tar)
RUN curl -L -o /tmp/novnc.tar.gz \
    https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz && \
    tar -xzf /tmp/novnc.tar.gz -C / && mv /noVNC-master /novnc && \
    ln -s /novnc/vnc.html /novnc/index.html

# websocat (WebSocket Bridge, không cần python)
RUN curl -L -o /usr/local/bin/websocat \
    https://github.com/vi/websocat/releases/latest/download/websocat_x86_64-linux && \
    chmod +x /usr/local/bin/websocat

# noVNC launcher
RUN echo '#!/bin/sh' > /novnc.sh && \
    echo 'echo "[OK] noVNC WebSocket running on :8081"' >> /novnc.sh && \
    echo 'websocat -b ws-l:0.0.0.0:8081 tcp:localhost:8006 &' >> /novnc.sh && \
    chmod +x /novnc.sh

# Cloudflare tunnel launcher
RUN echo '#!/bin/sh' > /tunnel.sh && \
    echo 'echo "[OK] Creating Cloudflare Tunnel..."' >> /tunnel.sh && \
    echo 'cloudflared tunnel --url http://localhost:8081' >> /tunnel.sh && \
    chmod +x /tunnel.sh

# Keepalive Railway
RUN echo '#!/bin/sh' > /alive.sh && \
    echo 'while true; do echo alive | nc -l -p 8080; done' >> /alive.sh && \
    chmod +x /alive.sh

EXPOSE 8080
EXPOSE 8081
EXPOSE 8006

ENTRYPOINT ["/usr/bin/tini","--"]
CMD sh /novnc.sh & sh /alive.sh & sh /tunnel.sh
