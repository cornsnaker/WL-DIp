# Use the Official Python 3.13 image
FROM python:3.13-slim-bookworm

# 1. FIX: Install 'uv' explicitly
# We copy the binary from the official image. This is the recommended, most reliable method.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Kolkata \
    # Configure uv settings
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Install essential system tools and build dependencies
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

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Set working directory
WORKDIR /app

# 2. OPTIMIZATION: Copy requirements FIRST to leverage Docker caching
# This prevents re-installing dependencies every time you change your code.
COPY requirements.txt .

# 3. Create Virtual Environment & Install Dependencies
# We set VIRTUAL_ENV so 'python' and 'pip' commands automatically use the venv.
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Run the install. We combine your extra packages (uvloop, httpx) into the single uv command.
RUN uv venv && \
    uv pip install --no-cache-dir -r requirements.txt uvloop httpx

# 4. Copy the rest of the application code
# This is done last so code changes don't invalidate the dependency install layer.
COPY . .

# Ensure the start script is executable
RUN chmod +x start.sh

# Start the bot
CMD ["bash", "start.sh"]
