#!/bin/bash

# Set the repository URL and target directory
repo_url="https://github.com/ns144/Transcription-Application.git"
target_dir="/home/ubuntu/Transcription-Application"
log_file="/var/log/Transcription-Application.log"

exec > >(tee -a "$log_file") 2>&1

# Check if the target directory exists and is a Git repository
if [ -d "$target_dir/.git" ]; then
# If it's a Git repository, pull the latest changes
cd "$target_dir"
git pull origin main
echo "Repository pulled."
else
# If it's not a Git repository, clone the repository
git clone "$repo_url" "$target_dir"

# Navigate to the repository directory
cd "$target_dir"
fi

# Install requirements
sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y python3-pip
sudo apt install -y ffmpeg
#pip install openai-whisper --no-cache-dir

pip install -r requirements.txt

sudo poweroff