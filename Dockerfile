FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Script chạy Cloudflare Tunnel nền + in link
RUN echo '#!/bin/bash\n\
cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 2>&1 | grep -Eo "https://[a-zA-Z0-9.-]*\.trycloudflare\.com"\n'\
> /usr/local/bin/run-tunnel && chmod +x /usr/local/bin/run-tunnel

# Khởi chạy Windows và cloudflare song song
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD bash -c "/usr/local/bin/run-tunnel & exec /init"
