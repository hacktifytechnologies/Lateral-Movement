#Requires -RunAsAdministrator
$PlayerUsr = "player"; $PlayerPwd = ConvertTo-SecureString "Player@123!" -AsPlainText -Force
$FlagPath  = "C:\Windows\System32\flag_T1550_003.txt"
$Flag      = "HACKTIFY{PASS_THE_TICKET_$($env:COMPUTERNAME)}"
if (-not (Get-LocalUser $PlayerUsr -EA SilentlyContinue)) {
    New-LocalUser $PlayerUsr -Password $PlayerPwd -FullName "Player" -PasswordNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member $PlayerUsr }
Set-Content $FlagPath $Flag
$acl = Get-Acl $FlagPath; $acl.SetAccessRuleProtection($true,$false)
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")))
Set-Acl $FlagPath $acl
# Simulate a ticket dump (fake Kerberos ticket info for learning)
Set-Content "C:\Users\Public\ticket_info.txt" @"
[*] Mimikatz kerberos::list output (simulated for lab)
[00000000] - 0x00000012 - aes256_hmac
   Start/End/MaxRenew: 1/1/2024 08:00 ; 1/1/2024 18:00 ; 1/8/2024 08:00
   Server Name       : krbtgt/CORP.LOCAL @ CORP.LOCAL
   Client Name       : domain_admin @ CORP.LOCAL
   Flags             : 40e10000 (forwardable renewable initial pre_authent name_canonicalize)
[Lab Note] In a real domain: mimikatz kerberos::ptc ticket.kirbi
           Or: Invoke-Mimikatz -Command 'kerberos::ptt ticket.kirbi'
           Impacket: python3 ticketer.py -nthash HASH -domain CORP.LOCAL -domain-sid S-... admin
"@
Set-Content "C:\Users\Public\Desktop\README.txt" @"
=== T1550.003 Pass-the-Ticket (Kerberos) ===
Login   : $PlayerUsr / Player@123!
Goal    : Understand Kerberos ticket abuse techniques.
          1. Read C:\Users\Public\ticket_info.txt — simulated ticket dump
          2. Understand the difference between PtH (NTLM) and PtT (Kerberos)
          3. Learn Golden Ticket vs Silver Ticket concepts
          4. Demonstrate ticket injection concept using klist/mimikatz
"@
Write-Host "[+] T1550.003 setup complete."
