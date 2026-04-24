#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1550_002.txt"
$Flag      = "HACKTIFY{PASS_THE_HASH_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Create target with known hash (we pre-compute and plant it)
$TgtUsr = "lm_target"; $TgtPwd = ConvertTo-SecureString "Welc0me@Corp!" -AsPlainText -Force
if (-not (Get-LocalUser $TgtUsr -EA SilentlyContinue)) {
    New-LocalUser $TgtUsr -Password $TgtPwd -FullName "LM Target" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $TgtUsr }
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
# Plant a "hash dump" file simulating output from mimikatz sekurlsa::logonpasswords
Set-Content "C:\Users\Public\hash_dump.txt" @"
[*] Mimikatz sekurlsa::logonpasswords output (simulated)
Authentication Id : 0 ; 217458
Session           : Interactive from 1
User Name         : lm_target
Domain            : HACKTIFY-LAB
Logon Server      : HACKTIFY-LAB
Logon Time        : 2024-01-01 10:00:00
SID               : S-1-5-21-1234567890-1
msv :
  [00000003] Primary
  * Username : lm_target
  * Domain   : HACKTIFY-LAB
  * NTLM     : 8c6976e5b5410415bde908bd4dee15df
  * SHA1     : e38ad214943daad1d64c102faec29de4afe9da3a
tspkg : (null)
wdigest: (null)
kerberos:
  * Username : lm_target
  * Password : (null)
credman : (null)
[NOTE] The NTLM hash above is for password: 'admin' (demo hash for lab purposes)
[NOTE] Real lm_target password is: Welc0me@Corp!
"@
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1550.002 Pass-the-Hash ===
Login   : $PlayerUsr / Player@123!
Goal    : Use a captured NTLM hash to authenticate as lm_target WITHOUT knowing the password.
          1. Read C:\Users\Public\hash_dump.txt to get the NTLM hash
          2. Use Invoke-WmiMethod or pth-winexe with the hash
          3. OR: use Impacket's wmiexec.py / psexec.py with --hashes flag
          4. Retrieve the flag from C:\Windows\System32\flag_T1550_002.txt
          Note: Real PTH requires tools like mimikatz/Impacket. Lab includes actual creds.
          Real user creds (for comparison): lm_target / Welc0me@Corp!
"@
Write-Host "[+] T1550.002 setup complete."
