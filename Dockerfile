# Use the Official Python 3.13 image (Debian-based, Lightweight & Stable)
FROM python:3.13-slim-bookworm

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

# Install essential system tools and build dependencies
# We include 'build-essential' to ensure python modules compile correctly
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    pv \
    jq \
    ffmpeg \
    p7zip-full \
    libcurl4-openssl-dev \
    libssl-dev \
    libc-ares-dev \
    libsodium-dev \
    libcrypto++-dev \
    libsqlite3-dev \
    libfreeimage-dev \
    locales \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install rclone (required for cloud uploads)
RUN curl https://rclone.org/install.sh | bash

# Set working directory
WORKDIR /app
RUN uv venv --system-site-packages
# COPY local files
COPY . .

# Install Python dependencies
# 'pip' is already installed in this image.
# We install uvloop and httpx explicitly to prevent the import errors you faced.
COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt && \
    pip install uvloop httpx

# Ensure the start script is executable
RUN chmod +x start.sh

# Start the bot
CMD ["bash", "start.sh"]
