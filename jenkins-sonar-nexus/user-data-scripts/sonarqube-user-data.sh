#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y docker.io
sudo usermod -aG docker ubuntu
sudo newgrp docker
docker run -d -p 9000:9000 sonarqube:lts-community
