# T1091 – Replication Through Removable Media | Solution Walkthrough
**Difficulty:** Easy | **OS:** Windows | **MITRE:** T1091

## Background
Stuxnet used USB drives to jump air-gapped networks. Modern techniques use malicious
LNK shortcuts since autorun.inf is disabled in Windows 7+.

## Step 1 – Analyse USB Contents
```powershell
Get-ChildItem "C:\SimulatedUSB" -Force
# autorun.inf  ← legacy technique (disabled Win7+)
# payload.bat  ← the actual payload
# Documents.lnk ← malicious shortcut disguised as folder
cat "C:\SimulatedUSB\autorun.inf"
# [AutoRun] open=payload.bat  ← would auto-run on XP/Vista
$sh = New-Object -ComObject WScript.Shell
$lnk = $sh.CreateShortcut("C:\SimulatedUSB\Documents.lnk")
$lnk.TargetPath  # cmd.exe
$lnk.Arguments   # /c type flag... (malicious!)
```

## Step 2 – Execute Legacy Payload
```cmd
cmd /c "C:\SimulatedUSB\payload.bat"
```

## Step 3 – Execute Modern LNK Payload
```powershell
Start-Process "C:\SimulatedUSB\Documents.lnk"
```

## Step 4 – Retrieve Flag
```powershell
Get-Content "C:\Users\Public\flag_usb.txt"
# HACKTIFY{REMOVABLE_MEDIA_<hostname>}
```

## Air-Gap Jump Technique (Stuxnet-style)
```
USB inserted → autorun.inf executes payload → payload copies itself to all USB drives
→ Travels to air-gapped ICS/SCADA network via infected USB → Stuxnet payload activates
```
