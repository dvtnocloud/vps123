# ================================
#  WINDOWS + CLOUDFLARE TUNNEL
#  KHÔNG CẦN ĐĂNG NHẬP
# ================================
FROM dockurr/windows:latest

USER root
RUN apt update && \
    apt install -y curl && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Chạy Windows + Cloudflared cùng lúc
CMD cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 \
    2>&1 | grep -Eo 'https://[-a-zA-Z0-9\.]+' & \
    echo ">>> Đợi vài giây để tạo link..." && \
    exec /init
