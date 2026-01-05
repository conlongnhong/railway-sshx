# ===============================
#   UBUNTU + WINE (Windows Emulator)
#   Railway Ready
# ===============================
FROM ubuntu:22.04

# Tránh hỏi khi apt install
ENV DEBIAN_FRONTEND=noninteractive

# Timezone Việt Nam
ENV TZ=Asia/Ho_Chi_Minh

# Port cho web service ảo
ENV PORT=8080

# -------------------------------
# 1. Cài đặt Wine và các gói cần thiết
# -------------------------------
# Chúng ta cần enable kiến trúc 32-bit (i386) để Wine hoạt động tốt nhất
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    curl \
    wget \
    python3 \
    tzdata \
    wine \
    wine32 \
    wine64 \
    && ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# 2. Tải SSHX phiên bản WINDOWS (.exe)
# -------------------------------
# Lưu ý: Ta tải file .exe về nhưng sẽ chạy nó bằng lệnh 'wine'
RUN curl -L https://sshx.s3.amazonaws.com/sshx-x86_64-pc-windows-msvc.zip -o sshx.zip && \
    apt-get update && apt-get install -y unzip && \
    unzip sshx.zip && \
    rm sshx.zip

# -------------------------------
# Command chạy:
# 1. Start web service ảo (python)
# 2. Chạy sshx.exe thông qua Wine
# -------------------------------
CMD bash -c '\
echo "🍷 Starting Fake Windows Environment (Wine)..."; \
python3 -m http.server $PORT >/dev/null 2>&1 & \
echo "🚀 Starting SSHX for Windows..."; \
wine sshx.exe \
'
