#!/bin/bash

set -e

echo "[+] Updating package lists..."
sudo apt-get update

echo "[+] Installing required packages..."
sudo apt-get install -y gnupg software-properties-common unzip curl git

# --- Terraform ---
echo "[+] Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install -y terraform

echo "[✓] Terraform version:"
terraform -version || echo "Terraform installation failed."

# --- AWS CLI v2 ---
echo "[+] Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

echo "[✓] AWS CLI version:"
aws --version || echo "AWS CLI installation failed."

# --- Git ---
echo "[✓] Git version:"
git --version || echo "Git installation failed."

# --- kubectl ---
echo "[+] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo "[✓] kubectl version:"
kubectl version --client || echo "kubectl installation failed."

echo "[✔] All installations completed and verified."
