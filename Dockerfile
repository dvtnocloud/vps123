FROM dockurr/windows:latest
USER root

# Tải Cloudflare binary trực tiếp
ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared

# Tải noVNC portable + websockify portable
ADD https://github.com/novnc/noVNC/archive/refs/heads/master.zip /tmp/novnc.zip
ADD https://github.com/novnc/websockify/archive/refs/heads/master.zip /tmp/websockify.zip
RUN unzip /tmp/novnc.zip -d / && mv /noVNC-master /novnc && ln -s /novnc/vnc.html /novnc/index.html && \
    unzip /tmp/websockify.zip -d / && mv /websockify-master /websockify && chmod +x /websockify/run

# Script chạy noVNC
RUN echo '#!/bin/sh' > /novnc.sh && \
    echo 'echo "[OK] noVNC running at :8081"' >> /novnc.sh && \
    echo '/websockify/run 8081 localhost:8006 --web=/novnc &' >> /novnc.sh && \
    chmod +x /novnc.sh

# Script chạy Cloudflare Tunnel
RUN echo '#!/bin/sh' > /tunnel.sh && \
    echo 'echo "[OK] Creating Cloudflare Tunnel..."' >> /tunnel.sh && \
    echo 'cloudflared tunnel --url http://localhost:8081' >> /tunnel.sh && \
    chmod +x /tunnel.sh

# Keepalive Railway
RUN echo '#!/bin/sh' > /alive.sh && \
    echo 'while true; do echo alive | nc -l -p 8080; done' >> /alive.sh && \
    chmod +x /alive.sh

ENV SCREEN_RESOLUTION="1280x720"
ENV USERNAME="Code-chillmusic"
ENV PASSWORD="admin123"

EXPOSE 8080
EXPOSE 8081
EXPOSE 8006

ENTRYPOINT ["/usr/bin/tini","--"]
CMD sh /novnc.sh & sh /alive.sh & sh /tunnel.sh
