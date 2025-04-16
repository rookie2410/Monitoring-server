#!/bin/bash

# Update packages and install git
sudo apt update -y
sudo apt install -y git

# Install Jenkins
sudo apt install -y wget gnupg2
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y openjdk-17-jdk
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
sudo chmod 777 /var/run/docker.sock
sudo systemctl enable docker
sudo systemctl start docker

# Install Trivy
sudo apt install -y wget apt-transport-https gnupg lsb-release
wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb
sudo apt install -y ./trivy_0.18.3_Linux-64bit.deb

# Run SonarQube container
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
