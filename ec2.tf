# IAM Role for EC2 instance
resource "aws_iam_role" "access_s3" {
  name = "access_s3_role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.access_s3.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.access_s3.name
}

# Additional policy for accessing Secrets Manager
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets_manager_policy"
  description = "Policy for accessing AWS Secrets Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = aws_iam_role.access_s3.name
}



resource "aws_instance" "transcription_server" {
# AMI Ubuntu Server 22.04 LTS X86 
  ami           = "ami-06dd92ecc74fdfb36"

  instance_type = "t2.micro"

  # Assign a public IP address
  associate_public_ip_address = true

  # Should make shure that ec2 is not running initially
  user_data = "${file("init_transcript.sh")}"  
  user_data_replace_on_change = true

  tags = {

    Name = "Transcription Server"

  }
  # Security Group allowing traffic from everywhere (0.0.0.0/0)
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name = "ssh_access"

  # IAM Role for S3 access
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 15  # New root volume size in GB
  }
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