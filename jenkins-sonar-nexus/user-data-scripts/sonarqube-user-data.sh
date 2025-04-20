#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io
usermod -aG docker ubuntu
newgrp docker
docker run -d -p 9000:9000 sonarqube:lts-community
