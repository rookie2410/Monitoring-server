provider "aws" {
  region = "us-east-1"
}


# resource "aws_key_pair" "deployer" {
#   key_name   = var.key_name
#   public_key = file("~/.ssh/id_rsa.pub")
# }

resource "aws_security_group" "allow_required_ports" {
  name        = "allow_required_ports"
  description = "Allow required ports for Jenkins, Nexus, SonarQube, SSH, HTTP/HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port range 500-1000"
    from_port   = 500
    to_port     = 1000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port range 1000-11000"
    from_port   = 1000
    to_port     = 11000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-nexus-sonarqube-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_required_ports.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "Jenkins"
  }

  user_data = file("user-data-scripts/jenkins-user-data.sh")
}

resource "aws_instance" "sonarqube" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_required_ports.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "SonarQube"
  }

  user_data = file("user-data-scripts/sonarqube-user-data.sh")
}

resource "aws_instance" "nexus" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_required_ports.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "Nexus"
  }

  user_data = file("user-data-scripts/nexus-user-data.sh")
}
