# Specify the provider
provider "aws" {
  region = "ap-south-1" # Change to your preferred region
}

# Define the key pair (adjust as needed)
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public SSH key
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access (restrict to your IP in production)
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins HTTP access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "jenkins_instance" {
  ami           = "ami-023a307f3d27ea427" # Ubuntu 22.04 AMI for us-west-2
  instance_type = "t2.micro"

  key_name      = aws_key_pair.jenkins_key.key_name
  security_groups = [aws_security_group.jenkins_sg.name]

  user_data = templatefile("./jenkins_configuration.sh", {})

  tags = {
    Name = "Jenkins-Server"
  }
  
  # Connection details
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa") # Path to your private SSH key
    host        = self.public_ip
  }

}

# Output Jenkins Public IP
output "jenkins_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
  description = "Public IP of the Jenkins instance"
}
