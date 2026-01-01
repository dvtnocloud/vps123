FROM dockurr/windows:latest
USER root

# Cloudflare binary
ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared

# noVNC (tar.gz - không cần unzip)
ADD https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz /tmp/novnc.tar.gz
ADD https://github.com/novnc/websockify/archive/refs/heads/master.tar.gz /tmp/websockify.tar.gz

RUN tar -xzf /tmp/novnc.tar.gz -C / && mv /noVNC-master /novnc && ln -s /novnc/vnc.html /novnc/index.html && \
    tar -xzf /tmp/websockify.tar.gz -C / && mv /websockify-master /websockify && chmod +x /websockify/run

# noVNC start
RUN echo '#!/bin/sh' > /novnc.sh && \
    echo 'echo "[OK] noVNC running at :8081"' >> /novnc.sh && \
    echo '/websockify/run 8081 localhost:8006 --web=/novnc &' >> /novnc.sh && \
    chmod +x /novnc.sh

# Cloudflare tunnel
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
