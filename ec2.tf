resource "aws_instance" "transcription_server" {
# AMI Ubuntu Server 22.04 LTS X86 
  ami           = "ami-06dd92ecc74fdfb36"

  instance_type = "t2.micro"

  # Assign a public IP address
  associate_public_ip_address = true

  # Should make shure that ec2 is not running initially
  user_data = "${file("init.sh")}"  

  tags = {

    Name = "Transcription Server"

  }
  # Security Group allowing traffic from everywhere (0.0.0.0/0)
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name = "ssh_access"
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

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_key_pair" "ssh_access" {
#  key_name   = "ssh-key"
#  public_key = tls_private_key.rsa_4096_key.public_key_openssh
#}
#
## RSA key of size 4096 bits
#resource "tls_private_key" "rsa_4096_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

#resource "aws_ec2_instance_state" "state_stopped" {
#  instance_id = aws_instance.transcription_server.id
#  state       = "stopped"
#}