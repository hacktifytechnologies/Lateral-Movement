# T1534 – Internal Spearphishing | Solution Walkthrough
**Difficulty:** Intermediate | **OS:** Linux | **MITRE:** T1534

## Background
T1534 uses compromised internal accounts to send phishing messages to other internal users.
Because it comes from a trusted internal source, users are more likely to comply.

## Step 1 – Read the Phishing Email
```bash
cat ~/inbox/mail_from_it.txt
# From: it-helpdesk@corp.internal
# "Run: bash /opt/it-tools/password_reset.sh"
```

## Step 2 – Analyse the Script (Red Team Perspective)
```bash
cat /opt/it-tools/password_reset.sh
# Line: cat /root/.flags/flag.txt > /tmp/spearphish_flag.txt
# "IT tool" is actually exfiltrating a sensitive file!
file /opt/it-tools/password_reset.sh   # shell script
strings /opt/it-tools/password_reset.sh | grep -E 'flag|curl|wget|nc'
```

## Step 3 – Execute (Simulating Victim)
```bash
bash /opt/it-tools/password_reset.sh
```

## Step 4 – Retrieve Flag
```bash
cat /tmp/spearphish_flag.txt
# HACKTIFY{INTERNAL_SPEARPHISH_<hash>}
```

## Craft Your Own Internal Phish (Red Team)
```python
import smtplib
from email.mime.text import MIMEText
msg = MIMEText("Please run /tmp/update.sh to apply critical security patch.")
msg['Subject'] = 'URGENT: Security Patch Required'
msg['From'] = 'it-security@corp.internal'  # Spoofed internal sender
msg['To'] = 'target@corp.internal'
# Send via compromised internal mail server
```
