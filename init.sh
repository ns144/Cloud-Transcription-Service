#!/bin/bash

# Set the repository URL and target directory
repo_url="https://github.com/hyqshr/whispercpp-fastapi.git"
target_dir="/home/ubuntu/whispercpp-fastapi"
log_file="/var/log/whispercpp-fastapi.log"

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
pip install -r requirements.txt
sudo apt install -y nginx

public_ip=$(curl http://checkip.amazonaws.com)

echo "Public IP: $public_ip"

sudo rm -rf /etc/nginx/sites-available/fastapi_nginx

# Configure Nginx server block
sudo cat >/etc/nginx/sites-enabled/fastapi_nginx <<EOL
server {
    listen 80;
    server_name $public_ip;
    location / {
        proxy_pass http://127.0.0.1:8000;
    }

}
EOL
sudo cat /etc/nginx/sites-enabled/fastapi_nginx

# Configure Startup Script
sudo cat >/home/ubuntu/startup.sh <<EOL
#!/bin/bash

log_file="/var/log/startup.log"
target_dir="/home/ubuntu/whispercpp-fastapi"

exec > >(tee -a "\$log_file") 2>&1

public_ip=\$(curl http://checkip.amazonaws.com)

echo "Public IP: \$public_ip"

sudo rm -rf /etc/nginx/sites-available/fastapi_nginx

sudo cat >/etc/nginx/sites-enabled/fastapi_nginx <<NGINX_CONF
server {
    listen 80;
    server_name \$public_ip;

    location / {
        proxy_pass http://127.0.0.1:8000;
    }
}
NGINX_CONF
sudo cat /etc/nginx/sites-enabled/fastapi_nginx

sudo service nginx restart
cd "\$target_dir"

python3 -m uvicorn main:app --reload
EOL
sudo cat /home/ubuntu/startup.sh

# Enable Startup Script
sudo chmod +x /home/ubuntu/startup.sh

# Autostart
sudo cat >/etc/cron.d/startup_script <<EOL
@reboot root /home/ubuntu/startup.sh
EOL
sudo cat /etc/cron.d/startup_script

# Restart Nginx to apply changes
sudo service nginx restart

sudo poweroff

# python3 -m uvicorn main:app --reload
# echo "App started"