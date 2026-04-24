#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1550_002b.txt"
$Flag      = "HACKTIFY{NTLM_RELAY_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Disable SMB signing (prerequisite for NTLM relay)
Set-SmbServerConfiguration -RequireSecuritySignature $false -EnableSecuritySignature $false -Confirm:$false -EA SilentlyContinue
Set-SmbClientConfiguration -RequireSecuritySignature $false -Confirm:$false -EA SilentlyContinue
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1550.002 NTLM Relay Attack ===
Login   : $PlayerUsr / Player@123!
Goal    : Understand and simulate NTLM Relay attack.
          SMB signing has been DISABLED on this system (prerequisite for relay).
          1. Verify SMB signing status: Get-SmbServerConfiguration | Select RequireSecuritySignature
          2. Understand the attack: Responder poisoning → ntlmrelayx relay
          3. From attacker Linux: python3 ntlmrelayx.py -t smb://<target> -smb2support
          4. Simulate by reading the flag directly (demonstrate the vulnerability exists)
"@
Write-Host "[+] T1550.002-B setup complete."
