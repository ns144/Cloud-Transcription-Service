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

pip install openai-whisper --no-cache-dir
pip install faster-whisper
pip install git+https://github.com/jiaaro/pydub.git@master
pip install pyannote.audio

pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

pip install -r requirements.txt

# Configure Startup Script
sudo cat >/home/ubuntu/startup.sh <<EOL
#!/bin/bash

log_file="/var/log/startup.log"
target_dir="/home/ubuntu/Transcription-Application"

exec > >(tee -a "\$log_file") 2>&1

cd "\$target_dir"
sudo git pull
sudo python3 main.py

sudo poweroff -f

EOL
sudo cat /home/ubuntu/startup.sh

# Enable Startup Script
sudo chmod +x /home/ubuntu/startup.sh

# Autostart
sudo cat >/etc/cron.d/startup_script <<EOL
@reboot root /home/ubuntu/startup.sh
EOL
sudo cat /etc/cron.d/startup_script