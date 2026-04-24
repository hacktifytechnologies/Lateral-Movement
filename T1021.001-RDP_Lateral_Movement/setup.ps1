#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1021_001.txt"
$Flag      = "HACKTIFY{RDP_LATERAL_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Enable RDP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -EA SilentlyContinue
# Create RDP-enabled target account
$RdpUsr = "rdp_target"; $RdpPwd = ConvertTo-SecureString "RdpTarget2024!" -AsPlainText -Force
if (-not (Get-LocalUser $RdpUsr -EA SilentlyContinue)) {
    New-LocalUser $RdpUsr -Password $RdpPwd -FullName "RDP Target" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $RdpUsr
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $RdpUsr }
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1021.001 RDP Lateral Movement ===
Login   : $PlayerUsr / Player@123!
Goal    : Use RDP to laterally move to rdp_target account.
          rdp_target credentials: rdp_target / RdpTarget2024!
          1. Connect via mstsc.exe (GUI) or from Linux: xfreerdp /v:localhost /u:rdp_target
          2. From command line: cmdkey + mstsc /v:host
          3. Use xfreerdp to avoid GUI interaction
          4. Retrieve the flag from $FlagPath
"@
Write-Host "[+] T1021.001 setup complete."
