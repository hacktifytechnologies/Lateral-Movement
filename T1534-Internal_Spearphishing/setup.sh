#!/bin/bash
set -euo pipefail
PLAYER="player"; PASS="Player@123"
FLAG="HACKTIFY{INTERNAL_SPEARPHISH_$(hostname|sha256sum|cut -c1-8)}"
id "$PLAYER" &>/dev/null || { useradd -m -s /bin/bash "$PLAYER"; echo "$PLAYER:$PASS"|chpasswd; }
echo "$PLAYER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/player-lm6; chmod 440 /etc/sudoers.d/player-lm6
mkdir -p /root/.flags && chmod 700 /root/.flags
echo "$FLAG" > /root/.flags/flag.txt && chmod 644 /root/.flags/flag.txt
# Create a phishing scenario — plant an "email" lure
mkdir -p /home/$PLAYER/inbox
cat > /home/$PLAYER/inbox/mail_from_it.txt << 'MAILEOF'
From: it-helpdesk@corp.internal
To: player@corp.internal
Subject: URGENT: Password Reset Required

Dear Player,

Your account password has expired. Please click the link below or run the
attached script to reset your password immediately.

Run: bash /opt/it-tools/password_reset.sh

This is automated. Do not reply.
IT Security Team
MAILEOF
# The "malicious" script planted by attacker in a shared location
mkdir -p /opt/it-tools && chmod 755 /opt/it-tools
cat > /opt/it-tools/password_reset.sh << 'PRSEOF'
#!/bin/bash
# "IT Password Reset Tool" — actually a malicious script
echo "[*] Connecting to IT server..."
sleep 1
echo "[*] Verifying identity..."
sleep 1
cat /root/.flags/flag.txt > /tmp/spearphish_flag.txt 2>/dev/null
chmod 644 /tmp/spearphish_flag.txt 2>/dev/null
echo "[*] Password reset complete. New password sent to your email."
PRSEOF
chmod 755 /opt/it-tools/password_reset.sh
chown -R $PLAYER:$PLAYER /home/$PLAYER/inbox
cat > /home/$PLAYER/README.txt << 'RMEOF'
=== T1534 Internal Spearphishing ===
Login  : player / Player@123
Scenario: An attacker who has already compromised an internal account sends
          a phishing email to another internal user (player) pretending to be IT.
Goal   : 1. Read ~/inbox/mail_from_it.txt (the phishing email)
         2. "Fall for it" — execute the script as instructed in the email
         3. Retrieve the flag from /tmp/spearphish_flag.txt
         4. Understand what the script actually does (red team analysis)
RMEOF
chown $PLAYER:$PLAYER /home/$PLAYER/README.txt
echo "[+] T1534 setup complete."
