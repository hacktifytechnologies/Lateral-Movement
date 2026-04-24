#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1091.txt"
$Flag      = "HACKTIFY{REMOVABLE_MEDIA_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Simulate USB content directory
$UsbSim = "C:\SimulatedUSB"
New-Item -ItemType Directory -Path $UsbSim -Force | Out-Null
@"
[AutoRun]
open=payload.bat
action=Open folder to view files
label=USB Drive
"@ | Set-Content "$UsbSim\autorun.inf"
@"
@echo off
type C:\Windows\System32\flag_T1091.txt > C:\Users\Public\flag_usb.txt
echo Payload executed from removable media!
"@ | Set-Content "$UsbSim\payload.bat"
@'
# LNK-based autorun for modern Windows (autorun.inf disabled post-Vista)
# Create a .lnk that appears as folder shortcut but runs payload
'@ | Set-Content "$UsbSim\README_for_challenge.txt"
$WshShell = New-Object -ComObject WScript.Shell
$lnk = $WshShell.CreateShortcut("$UsbSim\Documents.lnk")
$lnk.TargetPath = "cmd.exe"
$lnk.Arguments  = "/c type C:\Windows\System32\flag_T1091.txt > C:\Users\Public\flag_usb.txt && start explorer"
$lnk.IconLocation = "C:\Windows\System32\shell32.dll,3"
$lnk.Save()
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1091 Replication Through Removable Media ===
Login   : $PlayerUsr / Player@123!
Goal    : Simulate USB-based lateral movement (e.g., Stuxnet technique).
          Simulated USB contents: C:\SimulatedUSB\
          1. Review autorun.inf (legacy autorun technique)
          2. Review Documents.lnk (modern technique - looks like folder, runs payload)
          3. Execute: start C:\SimulatedUSB\Documents.lnk
          4. Retrieve: type C:\Users\Public\flag_usb.txt
"@
Write-Host "[+] T1091 setup complete."
