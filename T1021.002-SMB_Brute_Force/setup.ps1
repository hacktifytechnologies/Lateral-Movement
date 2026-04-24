#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1021_002c.txt"
$Flag      = "HACKTIFY{SMB_BRUTE_LATERAL_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Create target with weak password
$WeakUsr = "backup_svc"; $WeakPwd = ConvertTo-SecureString "backup123" -AsPlainText -Force
if (-not (Get-LocalUser $WeakUsr -EA SilentlyContinue)) {
    New-LocalUser $WeakUsr -Password $WeakPwd -FullName "Backup Service" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $WeakUsr }
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
# Create a simple password list
Set-Content "C:\Users\Public\passwords.txt" "password`r`nadmin`r`nbackup123`r`nwelcome`r`npassword1`r`nP@ssw0rd"
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1021.002 SMB Credential Brute Force ===
Login   : $PlayerUsr / Player@123!
Goal    : Brute-force SMB credentials for "backup_svc" account.
          Wordlist: C:\Users\Public\passwords.txt
          Method:
          foreach (pass in passwords.txt) { try net use \\localhost\C$ /user:backup_svc <pass> }
          Use valid creds to access C$ and retrieve the flag.
"@
Write-Host "[+] SMB brute setup complete."
