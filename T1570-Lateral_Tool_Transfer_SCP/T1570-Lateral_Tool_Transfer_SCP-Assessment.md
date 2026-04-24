# T1570 – Lateral Tool Transfer | Assessment

## MCQ 1
Attackers transfer tools to compromised hosts rather than downloading from the internet to:
A) Get faster download speeds  B) Avoid internet egress detection and bypass network perimeter controls  ✅
C) Guarantee tool compatibility  D) Reduce attack complexity

## MCQ 2
`python3 -m http.server 8080` on a compromised host creates a risk because:
A) It only serves Python files  B) It exposes the host's file system to anyone who can reach port 8080  ✅
C) It requires root to run  D) It only works on Linux

## MCQ 3
Base64-encoding a tool before transfer via SSH command execution helps because:
A) It compresses the tool  B) It avoids binary data issues in shell command arguments and evades simple content inspection  ✅
C) It encrypts the tool permanently  D) SSH cannot transfer binary files

## Fill 1
`scp` flag for recursive directory transfer:
**Answer:** `-r`

## Fill 2
Netcat command to listen on port 4445 and write received data to a file:
**Answer:** `nc -l 4445 > output_file`
