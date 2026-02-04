#!/bin/bash

# 1. Clone the repository
# We remove the folder first if it exists to ensure a fresh clone every time
if [ -d "MLV" ]; then
    echo "Removing old MLV folder..."
    rm -rf MLV
fi

echo "Cloning MLV repository..."
git clone https://github.com/cornsnaker/MLV

# 2. Use this repo (Enter the directory)
cd MLV

# 3. Install dependencies
echo "Installing requirements..."

# Install the specific packages you requested
pip3 install git+https://github.com/zevtyardt/lk21.git
pip3 install qbittorrent-api aria2p

# Install the repository's internal requirements
pip3 install -U -r requirements.txt

# Install the fixes for errors we found previously (uvloop and httpx)
pip3 install uvloop httpx

# 4. Start the bot
echo "Starting Bot..."
python3 update.py && python3 -m bot
