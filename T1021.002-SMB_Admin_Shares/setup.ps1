#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1021_002.txt"
$Flag      = "HACKTIFY{SMB_ADMIN_SHARES_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
# Create target user simulating a remote admin account
$TgtUsr = "admin_target"; $TgtPwd = ConvertTo-SecureString "Admin@Target99!" -AsPlainText -Force
if (-not (Get-LocalUser $TgtUsr -EA SilentlyContinue)) {
    New-LocalUser $TgtUsr -Password $TgtPwd -FullName "Admin Target" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $TgtUsr }
# Create a share with the flag (simulates remote host's admin share)
$SharePath = "C:\SharedTarget"
New-Item -ItemType Directory -Path $SharePath -Force | Out-Null
Set-Content "$SharePath\flag.txt" $Flag
$ShareAcl = New-Object System.Security.AccessControl.DirectorySecurity
$ShareAcl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")))
Set-Acl $SharePath $ShareAcl
New-SmbShare -Name "Target$" -Path $SharePath -FullAccess "Everyone" -EA SilentlyContinue
Set-Content $FlagPath $Flag
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1021.002 SMB / Windows Admin Shares ===
Login   : $PlayerUsr / Player@123!
Goal    : Use SMB to access shares and execute commands laterally.
          Target account: admin_target / Admin@Target99!
          1. List shares on localhost: net view \\localhost /all
          2. Map admin share: net use Z: \\localhost\C$ /user:admin_target Admin@Target99!
          3. Access Target$ share: net use Y: \\localhost\Target$ /user:admin_target Admin@Target99!
          4. Read Y:\flag.txt  OR  C:\Windows\System32\flag_T1021_002.txt
"@
Write-Host "[+] T1021.002 setup complete."
