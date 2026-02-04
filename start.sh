#!/bin/bash
set -e

# Update package list
sudo apt-get update

# Install aria2 and qbittorrent-nox
sudo apt-get install -y aria2 qbittorrent-nox

# Activate virtual environment and run the app
source .venv/bin/activate
python3 update.py && python3 -m bot
