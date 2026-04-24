#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1021_006.txt"
$Flag      = "HACKTIFY{WINRM_LATERAL_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
Enable-PSRemoting -Force -SkipNetworkProfileCheck -EA SilentlyContinue
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force -EA SilentlyContinue
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1021.006 WinRM / PowerShell Remoting ===
Login   : $PlayerUsr / Player@123!
Goal    : Use PowerShell Remoting (WinRM) to execute commands on localhost
          (simulates lateral movement to a remote host).
          Methods:
          1. Invoke-Command -ComputerName localhost -ScriptBlock { ... }
          2. Enter-PSSession -ComputerName localhost (interactive)
          3. New-PSSession + Invoke-Command (persistent session)
          Credentials: player / Player@123!
          Flag: $FlagPath
"@
Write-Host "[+] T1021.006 setup complete."
