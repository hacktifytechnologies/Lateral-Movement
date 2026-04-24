#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1570_smb.txt"
$Flag      = "HACKTIFY{LATERAL_TOOL_SMB_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
$ToolDir = "C:\ProgramData\attacker_tools"
New-Item -ItemType Directory -Path $ToolDir -Force | Out-Null
@"
@echo off
type C:\Windows\System32\flag_T1570_smb.txt > C:\Users\Public\tool_output.txt
echo Tool executed on %COMPUTERNAME%
"@ | Set-Content "$ToolDir\recon.bat"
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1570 Lateral Tool Transfer via SMB ===
Login   : $PlayerUsr / Player@123!
Goal    : Transfer and execute a tool using SMB shares.
          Attacker tool: C:\ProgramData\attacker_tools\recon.bat
          1. Map a share, copy tool, execute via wmic/schtasks/sc
          2. Use copy \\localhost\C$\ProgramData\attacker_tools\recon.bat \\target\C$\Windows\Temp\
          3. Execute remotely using wmic process call create
          4. Retrieve the flag from C:\Users\Public\tool_output.txt
"@
Write-Host "[+] T1570-B setup complete."
