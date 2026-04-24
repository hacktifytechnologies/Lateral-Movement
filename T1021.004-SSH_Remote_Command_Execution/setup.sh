#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{SSH_LATERAL_MOVE_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm; chmod 440 /etc/sudoers.d/player-lm
# Create a "target" user to simulate lateral movement
TARGET="target_srv"; TPASS="Target@321"
id "$TARGET" &>/dev/null || { useradd -m -s /bin/bash "$TARGET"; echo "$TARGET:$TPASS"|chpasswd; }
mkdir -p /home/$TARGET/.flags && chmod 700 /home/$TARGET/.flags
echo "$FLAG" > /home/$TARGET/.flags/flag.txt && chmod 600 /home/$TARGET/.flags/flag.txt
chown -R $TARGET:$TARGET /home/$TARGET/.flags
# Allow password auth in sshd
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
grep -q "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null || true
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1021.004 SSH Remote Command Execution (Lateral Movement) ===
Login  : player / Player@123
Goal   : Move laterally to "target_srv" account on this machine (simulates remote SSH LM)
         Credentials discovered: target_srv / Target@321
         1. SSH using password auth: ssh target_srv@localhost
         2. Execute commands remotely inline: ssh target_srv@localhost "id && cat .flags/flag.txt"
         3. Use sshpass for non-interactive auth: sshpass -p 'Target@321' ssh target_srv@localhost "cmd"
         4. Key-based auth: generate keys, copy to target, SSH without password
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1021.004-A setup complete."
