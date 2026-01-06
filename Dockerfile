# ===============================
#   UBUNTU + SSHX + GUI (XFCE/XRDP)
#   Railway Ready
# ===============================
FROM ubuntu:22.04

# Tránh hỏi khi apt install
ENV DEBIAN_FRONTEND=noninteractive

# Timezone Việt Nam
ENV TZ=Asia/Ho_Chi_Minh

# Railway web service port
ENV PORT=8080

# Mật khẩu cho Remote Desktop (Root)
# BẠN CÓ THỂ ĐỔI '123456' THÀNH MẬT KHẨU KHÁC
ENV ROOT_PASSWORD=123456

# -------------------------------
# 1. Cài các gói cần thiết + GUI (XFCE4 & XRDP)
# -------------------------------
RUN apt update && apt install -y \
    curl \
    wget \
    tzdata \
    ca-certificates \
    python3 \
    sudo \
    # --- Gói giao diện ---
    xfce4 \
    xfce4-goodies \
    xrdp \
    xorg \
    dbus-x11 \
    && ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    # --- Cấu hình XRDP ---
    && sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/xserverbpp=24/xserverbpp=128/g' /etc/xrdp/xrdp.ini \
    && echo xfce4-session > /root/.xsession \
    # Sửa lỗi màn hình đen/ngắt kết nối trên một số container
    && echo "xfce4-session" > /etc/skel/.xsession \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Command chạy:
# 1. Đặt mật khẩu root
# 2. Start web service ảo (8080) - Để Railway xanh
# 3. Start XRDP (Remote Desktop)
# 4. Chạy sshx
# -------------------------------
CMD bash -c '\
# Set mật khẩu root
echo "root:$ROOT_PASSWORD" | chpasswd; \
echo "🔐 Root password set to: $ROOT_PASSWORD"; \
\
echo "🇻🇳 Timezone: $TZ"; \
\
# Start Fake Web
echo "🌐 Starting fake web service on port $PORT"; \
python3 -m http.server $PORT >/dev/null 2>&1 & \
\
# Start XRDP
echo "🖥️ Starting XRDP Service..."; \
service xrdp start; \
\
# Start SSHX
echo "🚀 Starting SSHX..."; \
curl -sSf https://sshx.io/get | sh -s run \
'
