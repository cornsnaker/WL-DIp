# Use the Official Python 3.13 image
FROM python:3.13-slim-bookworm

# 1. Install 'uv' efficiently using the official multi-stage copy method
# This is cleaner than pip installing it and avoids PEP 668 issues.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Kolkata \
    # Configure uv to use a specific venv and compilation settings
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    # specific to uv: ensures we install into the system or a venv correctly
    UV_PROJECT_ENVIRONMENT="/app/.venv"

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

# 2. CACHE OPTIMIZATION: Copy requirements FIRST
# By copying only requirements.txt first, we allow Docker to cache the installed packages.
# If you change your code (start.sh, main.py, etc.) but not requirements.txt,
# Docker will skip the installation step, saving huge amounts of time.
COPY requirements.txt .

# 3. Install Python dependencies using uv
# We create a virtual environment and add it to the path so standard 'python' commands work.
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Synchronize dependencies (install reqs + uvloop/httpx)
# We add uvloop and httpx directly to the command to ensure they are in the venv
RUN uv venv && \
    uv pip install --no-cache -r requirements.txt uvloop httpx

# 4. Copy the rest of the application code
# This happens last so code changes don't invalidate the dependency cache
COPY . .

# Ensure the start script is executable
RUN chmod +x start.sh

# Start the bot
CMD ["bash", "start.sh"]
