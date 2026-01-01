# ================================
#  WINDOWS + CLOUDFLARE TUNNEL
#  KHÔNG CẦN ĐĂNG NHẬP
# ================================
FROM dockurr/windows:latest

# Cài cloudflared
USER root
RUN apt update && \
    apt install -y curl && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Khởi động Windows + tạo tunnel
ENTRYPOINT bash -c "\
    echo '===== BẮT ĐẦU KHỞI CHẠY WINDOWS =====' && \
    /start.sh & \
    sleep 5 && \
    echo '===== TẠO CLOUDFARE TUNNEL KHÔNG CẦN LOGIN... =====' && \
    cloudflared tunnel --url http://localhost:8006 --no-autoupdate --protocol http2 2>&1 | grep -Eo 'https://[-a-zA-Z0-9\.]+'"
