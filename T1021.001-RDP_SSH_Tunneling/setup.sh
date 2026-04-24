#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{RDP_SSH_TUNNEL_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm4; chmod 440 /etc/sudoers.d/player-lm4
mkdir -p /root/.flags && chmod 700 /root/.flags
echo "$FLAG" > /root/.flags/flag.txt && chmod 644 /root/.flags/flag.txt
PIVOT="pivot_user"; PPWD="Pivot@99!"
id "$PIVOT" &>/dev/null || { useradd -m -s /bin/bash "$PIVOT"; echo "$PIVOT:$PPWD"|chpasswd; }
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
grep -q "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null || true
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1021.001 RDP via SSH Tunneling (Port Forwarding) ===
Login  : player / Player@123
Scenario: "Internal RDP" is only accessible from localhost (firewall blocks 3389 externally).
Goal   : Use SSH port forwarding to tunnel RDP through SSH, access the internal service.
Steps  :
  1. Set up local port forward: ssh -L 13389:localhost:3389 pivot_user@localhost (pw: Pivot@99!)
  2. Connect RDP to forwarded port: xfreerdp /v:127.0.0.1:13389
  3. Understand dynamic SOCKS proxy: ssh -D 1080 pivot_user@localhost
  4. Retrieve the flag after demonstrating port forwarding
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1021.001-B setup complete."
