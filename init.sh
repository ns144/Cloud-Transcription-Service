# Set the repository URL and target directory
repo_url="https://github.com/hyqshr/whispercpp-fastapi.git"
target_dir="/home/ubuntu/whispercpp-fastapi"

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
sudo apt-get install -y python3-pip
sudo apt install -y ffmpeg
pip install -r requirements.txt
sudo apt install nginx

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

# Restart Nginx to apply changes
sudo service nginx restart

python3 -m uvicorn main:app --reload
echo "App started"

#shutdown -h now