#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{TAINT_SHARED_CONTENT_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm5; chmod 440 /etc/sudoers.d/player-lm5
USER2="developer"; U2PASS="Dev@123"
id "$USER2" &>/dev/null || { useradd -m -s /bin/bash "$USER2"; echo "$USER2:$U2PASS"|chpasswd; }
# Shared directory where both users work
mkdir -p /opt/shared-scripts && chmod 1777 /opt/shared-scripts
# Developer has a startup script that sources shared utilities
cat > /home/$USER2/.bashrc_extra << 'RCEOF'
# Sources shared utility scripts
for f in /opt/shared-scripts/*.sh; do source "$f" 2>/dev/null; done
RCEOF
chown $USER2:$USER2 /home/$USER2/.bashrc_extra
echo "source ~/.bashrc_extra" >> /home/$USER2/.bashrc
chown $USER2:$USER2 /home/$USER2/.bashrc
# Create a legitimate script in shared folder
cat > /opt/shared-scripts/utils.sh << 'UTILEOF'
#!/bin/bash
alias ll='ls -la'
export EDITOR=vim
UTILEOF
chmod 755 /opt/shared-scripts/utils.sh
# Flag requires SYSTEM access
mkdir -p /root/.flags && chmod 700 /root/.flags
echo "$FLAG" > /root/.flags/flag.txt && chmod 644 /root/.flags/flag.txt
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1080 Taint Shared Content ===
Login  : player / Player@123
Scenario: The "developer" user sources ALL shell scripts from /opt/shared-scripts/ on login.
Goal   : 1. Write a malicious script to /opt/shared-scripts/ (world-writable)
         2. When developer logs in, your script runs in THEIR context
         3. Exfiltrate developer's data or escalate (simulate by reading flag)
Steps  : echo 'cp /root/.flags/flag.txt /tmp/tainted.txt; chmod 644 /tmp/tainted.txt' > /opt/shared-scripts/evil.sh
         su - developer (to trigger the sourced script)
         cat /tmp/tainted.txt
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1080 setup complete."
