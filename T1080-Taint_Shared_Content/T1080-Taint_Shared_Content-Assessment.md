# T1080 – Taint Shared Content | Assessment

## MCQ 1
T1080 Taint Shared Content is effective for lateral movement because:
A) It exploits network vulnerabilities  B) Malicious code injected into shared resources executes automatically when other users/systems access the shared content  ✅
C) It requires no file system access  D) Shared content always runs with SYSTEM privileges

## MCQ 2
A world-writable directory with the sticky bit (`drwxrwxrwt`) allows:
A) Anyone to execute files in the directory  B) Anyone to create/write files but only the owner (or root) can delete others' files  ✅
C) Only root to write to the directory  D) Group members to execute all files

## MCQ 3
Supply chain attacks are a form of T1080 because:
A) They target supply companies  B) Attackers inject malicious code into widely-used packages/libraries, infecting all systems that install or update them  ✅
C) They use network scanning  D) They only affect Windows systems

## Fill 1
Linux directory permission notation for world-writable with sticky bit:
**Answer:** `1777` (or `drwxrwxrwt`)

## Fill 2
Git configuration file that can be poisoned for T1080 code execution on repository operations:
**Answer:** `.git/hooks/` (e.g., `pre-commit`, `post-merge` hooks)
