#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1021_006b.txt"
$Flag      = "HACKTIFY{WINRM_CRED_LATERAL_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Create a "domain admin" whose creds are stored in a file (simulates cred dump)
$DomAdm = "corp_admin"; $DAPwd = ConvertTo-SecureString "Corp@Admin2024!" -AsPlainText -Force
if (-not (Get-LocalUser $DomAdm -EA SilentlyContinue)) {
    New-LocalUser $DomAdm -Password $DAPwd -FullName "Corp Admin" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $DomAdm }
Enable-PSRemoting -Force -SkipNetworkProfileCheck -EA SilentlyContinue
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force -EA SilentlyContinue
# Plant "discovered" credentials file (simulates finding creds in files)
Set-Content "C:\Users\Public\Documents\backup_config.txt" "db_user=corp_admin`r`ndb_pass=Corp@Admin2024!`r`nhost=dc01.corp.local"
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1021.006 WinRM – Credential-based Lateral Movement ===
Login   : $PlayerUsr / Player@123!
Goal    : 1. Find credentials in C:\Users\Public\Documents\backup_config.txt
          2. Use found credentials to Invoke-Command via WinRM
          3. Enumerate what corp_admin can access on localhost
          4. Retrieve the flag using corp_admin credentials
"@
Write-Host "[+] T1021.006-B setup complete."
