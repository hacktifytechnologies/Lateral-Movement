#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1563_002.txt"
$Flag      = "HACKTIFY{RDP_HIJACK_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -EA SilentlyContinue
$VictimUsr = "victim_rdp"; $VictimPwd = ConvertTo-SecureString "Victim@Session1!" -AsPlainText -Force
if (-not (Get-LocalUser $VictimUsr -EA SilentlyContinue)) {
    New-LocalUser $VictimUsr -Password $VictimPwd -FullName "Victim RDP User" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $VictimUsr
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $VictimUsr }
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1563.002 RDP Session Hijacking ===
Login   : $PlayerUsr / Player@123!
Goal    : Hijack an existing RDP session using tscon.exe.
          Victim account: victim_rdp / Victim@Session1!
          Steps:
          1. As victim: open new cmd.exe as victim_rdp, let it sit (simulates RDP session)
          2. As SYSTEM (player): query sessions: qwinsta
          3. Identify victim's session ID
          4. Hijack: tscon <SessionID> /dest:console /password:""
          Note: Requires SYSTEM or session owner privileges
"@
Write-Host "[+] T1563.002 setup complete."
