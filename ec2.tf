resource "aws_instance" "transcription_server" {
# AMI Ubuntu Server 22.04 LTS X86 
  ami           = "ami-06dd92ecc74fdfb36"

  instance_type = "t2.micro"

  # Should make shure that ec2 is not running initially
  user_data = <<-EOF
              #!/bin/bash
              echo "Instance initialized but not started."
              EOF  

  tags = {

    Name = "Transcription Server"

  }

}

resource "aws_ec2_instance_state" "state_stopped" {
  instance_id = aws_instance.transcription_server.id
  state       = "stopped"
}