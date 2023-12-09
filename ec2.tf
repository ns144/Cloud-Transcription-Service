resource "aws_instance" "transcription_server" {
# AMI Ubuntu Server 22.04 LTS X86 
  ami           = "ami-06dd92ecc74fdfb36"

  instance_type = "t2.micro"

  # Assign a public IP address
  associate_public_ip_address = true

  # Should make shure that ec2 is not running initially
  user_data = <<-EOF
              #!/bin/bash
              echo "Instance initialized but not started."

              # Install git
              sudo apt-get update
              sudo apt-get install -y git

              # Set the repository URL and target directory
              repo_url="https://github.com/hyqshr/whispercpp-fastapi.git"
              target_dir="/whispercpp-fastapi"

              # Check if the target directory exists and is a Git repository
              if [ -d "$target_dir/.git" ]; then
                # If it's a Git repository, pull the latest changes
                cd "$target_dir"
                git pull origin main
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

              cd /etc/nginx/sites-enabled/

              # Start your application or any other setup steps
              python3 -m uvicorn main:app --reload

              # Configure Nginx server block
              sudo tee /etc/nginx/sites-available/fastapi_nginx <<CONFIG
              server {
                listen 80;
                server_name 3.87.220.60;
                location / {
                    proxy_pass http://127.0.0.1:8000;
                }
            
              }
              CONFIG

              # Create a symbolic link to enable the server block
              sudo ln -s /etc/nginx/sites-available/your_server_block /etc/nginx/sites-enabled/

              # Remove default Nginx configuration
              sudo rm /etc/nginx/sites-enabled/default

              # Restart Nginx to apply changes
              sudo service nginx restart
              
              # Start Python App
              cd ~/whispercpp-fastapi
              python3 -m uvicorn main:app --reload

              EOF  

  tags = {

    Name = "Transcription Server"

  }
  # Security Group allowing traffic from everywhere (0.0.0.0/0)
  vpc_security_group_ids = [aws_security_group.allow_all.id]

}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_instance_state" "state_stopped" {
  instance_id = aws_instance.transcription_server.id
  state       = "stopped"
}