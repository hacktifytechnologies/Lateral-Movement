#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{SSH_KEY_HIJACK_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm2; chmod 440 /etc/sudoers.d/player-lm2
# Create target user with SSH keys already set up
TARGET="svc_account"; TPASS="Svc@xXx99"
id "$TARGET" &>/dev/null || { useradd -m -s /bin/bash "$TARGET"; echo "$TARGET:$TPASS"|chpasswd; }
mkdir -p /home/$TARGET/.ssh && chmod 700 /home/$TARGET/.ssh
# Generate SSH key for target (simulates a service account with key auth)
ssh-keygen -t rsa -b 2048 -f /home/$TARGET/.ssh/id_rsa -N "" -q
cat /home/$TARGET/.ssh/id_rsa.pub >> /home/$TARGET/.ssh/authorized_keys
chmod 600 /home/$TARGET/.ssh/authorized_keys /home/$TARGET/.ssh/id_rsa
chown -R $TARGET:$TARGET /home/$TARGET/.ssh
# Place flag in target's home
mkdir -p /home/$TARGET/.secret && chmod 700 /home/$TARGET/.secret
echo "$FLAG" > /home/$TARGET/.secret/flag.txt && chmod 600 /home/$TARGET/.secret/flag.txt
chown -R $TARGET:$TARGET /home/$TARGET/.secret
# Enable password auth
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
grep -q "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null || true
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1021.004 SSH Key Hijacking ===
Login  : player / Player@123
Goal   : The service account "svc_account" has SSH keys in /home/svc_account/.ssh/
         1. Find and read the private key (you have sudo access)
         2. Use the stolen key to SSH into the account without a password
         3. Read /home/svc_account/.secret/flag.txt
Hints  : sudo cat /home/svc_account/.ssh/id_rsa
         ssh -i /tmp/stolen_key svc_account@localhost
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1021.004-B setup complete."
