# T1570 – Lateral Tool Transfer via SMB | Assessment

## MCQ 1
Copying tools via `\\host\ADMIN$` requires:
A) The tool to be signed  B) Local administrator credentials on the target  ✅
C) SMB signing to be disabled  D) The tool to be less than 1MB

## MCQ 2
Combining tool transfer (SMB copy) with remote execution (WMI/sc.exe) is analogous to:
A) FTP upload  B) The PsExec technique — copy binary to admin share + install/run service  ✅
C) Docker deployment  D) A phishing attack

## MCQ 3
Forensic artifact created when a file is copied to C:\Windows\Temp via SMB:
A) No artifact created  B) Windows prefetch entry + SMB Event ID 4663 (object access)  ✅
C) Only prefetch  D) MFT entry only (no event log)

## Fill 1
Windows Event ID for object access (file read/write) when file auditing is enabled:
**Answer:** `4663`

## Fill 2
`robocopy` flag for silent/no-progress output (used in scripts):
**Answer:** `/NP` (no progress) or `/LOG:NUL`
