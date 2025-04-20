#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io
usermod -aG docker ubuntu
newgrp docker
docker run -d -p 8081:8081 sonatype/nexus3
