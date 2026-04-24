#!/bin/bash
apt-get update -y
apt-get install -y openssh-server openssh-client sshpass netcat-openbsd socat
systemctl enable ssh && systemctl start ssh || service ssh start || true
echo "[+] Linux LM deps installed."
