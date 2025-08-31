# Windows Command Cheat Sheet

## Firewall (FW)

| Command | Description |
|---------|-------------|
| `netsh firewall show config` | Show firewall configuration (pre-Windows 7) |
| `netsh firewall show config state` | Deprecated command. Use `netsh advfirewall` instead |
| `netsh advfirewall show domainprofile` | Show firewall settings for domain profile |
| `netsh advfirewall show publicprofile` | Show firewall settings for public profile |
| `netsh advfirewall show privateprofile` | Show firewall settings for private profile |
| `netsh advfirewall set allprofiles state on` | Enable firewall for all profiles |
| `netsh advfirewall set allprofiles state off` | Disable firewall for all profiles |
| `netsh advfirewall show allprofiles` | Show firewall settings for all profiles (domain, private, public) |
| `netsh advfirewall firewall show rule name=all` | Show all firewall rules |
| `netsh advfirewall set currentprofile logging` | Show firewall logging configuration |
| `%systemroot%\system32\LogFiles\Firewall\pfirewall.log` | Firewall log file location |


## Wi-Fi

| Command | Description |
|---------|-------------|
| `netsh wlan show networks` | Show available networks |
| `netsh wlan show profiles` | Show saved Wi-Fi profiles |
| `netsh wlan show profile name="SSID_NAME" key=clear` | Show Wi-Fi password for profile |


## IP / Proxy

| Command | Description |
|---------|-------------|
| `netsh interface ip show config` | Show current IP configuration |
| `netsh winhttp reset proxy` | Clear proxy configuration |
| `netsh winhttp show proxy` | Show WinHTTP proxy configuration (used by Windows Update, Office 365, etc.) |
| `netsh winhttp show advproxy` | Show Internet Options proxy (used by browsers like Edge, Chrome, Firefox) |
| `netsh interface ip set dns name="Ethernet" static <DNS_IP>` | Set DNS server |
| `arp -a` | Show ARP table |
| `route print` | Show routing table |
| `netstat -ano` | Show network connections and listening ports (used to identify open ports for port forwarding) |
| `netsh advfirewall firewall dump` | Dump firewall configuration |
| `ipconfig /setclassid` | Change/modify DHCP Class ID |
| `ipconfig /displaydns` | Display DNS cache |
| `ipconfig /flushdns` | Clear DNS cache |
| `ipconfig /registerdns` | Re-register DNS connections |
| `ipconfig /release` | Release all IP configuration |
| `ipconfig /release6` | Release IPv6 configuration |
| `ipconfig /renew` | Acquire new IP address from DHCP |
| `ipconfig /all` | Show full configuration details |


## WMIC

| Command | Description |
|---------|-------------|
| `wmic qfe` | List all installed updates (Quick Fix Engineering) |
| `wmic qfe list brief` | List summary of installed updates (essential info only) |
| `wmic qfe \| find "KBXXXXXX"` | Search for a specific update by KB number |
| `wmic qfe list full` | List detailed info for installed updates |
| `wmic qfe list brief /format:table` | Show updates in table format |
| `wmic qfe > installed_updates.txt` | Save update list to file |
| `wmic qfe get Caption, Description, HotFixID, InstalledOn` | Display selected fields |
| `wmic logicaldisk` | List logical disks |
| `wmic logicaldisk get caption, description, providername` | Show disk info |
| `WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntivirusProduct Get displayName` | Show installed antivirus |
| `wmic product get name, version` | List installed software |
| `wmic process get name, processid, status` | Show running processes with PID and status |
| `wmic nic get name, macaddress` | List NICs with MAC addresses |
| `wmic path Win32_Battery get EstimatedChargeRemaining` | Show battery level |
| `wmic bios get serialnumber` | Show BIOS serial number |
| `wmic cpu get name, maxclockspeed, status` | Show CPU info |
| `wmic memorychip get capacity, speed, manufacturer` | Show memory info |
| `wmic os get caption, version, buildnumber` | Show OS info |
| `wmic diskdrive get model, size, status` | Show disk drives info |
| `wmic useraccount get name, sid` | Show usernames and SIDs |


## Net Commands

| Command | Description |
|---------|-------------|
| `net user` | Show users on the local machine |
| `net user /domain` | Show users in the domain |
| `net user <username>` | Show user details (local) |
| `net user <username> /domain` | Show user details in the domain |
| `net user vipin Password@1 /add /domain` | Add a user with password to the domain |
| `net group /domain` | List groups in the domain |
| `net group <groupname> /domain` | List members of a domain group |
| `net localgroup <groupname>` | Show local group details |
| `net share` | List shared folders |
| `net view \\192.168.197.130` | Show computers and shared resources on target host |
| `net accounts` | Configure password & logon requirements (min length, expiry, history, etc.) |


## System Info

| Command | Description |
|---------|-------------|
| `systeminfo` | Show system information |
| `systeminfo \| findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"` | Show only OS name, version, and type |


## icacls

| Command | Description |
|---------|-------------|
| `icacls.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"` | Assign full control permissions |
| `icacls C:\Windows\System32\Utilman.exe /grant Everyone:F` | Grant full control to Everyone |
| *Usage in attacks:* Place payload (y.exe) in Startup, assign permissions with icacls, payload executes on user login to trigger reverse shell. |


## Registry (reg)

| Command | Description |
|---------|-------------|
| `reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"` | Show Internet proxy settings |
| `reg query HKEY_USERS` | Show all user SIDs |
| `reg query HKEY_CURRENT_USER\Software\{username}\PuTTY\Sessions\ /f "Proxy" /s` | Find PuTTY proxy credentials |
| `reg query HKEY_CURRENT_USER\Software` | Show installed applications |
| `reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer` | Show installer policy (user) |
| `reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer` | Show installer policy (machine) |
| `REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f` | Add LocalAccountTokenFilterPolicy (bypass UAC) |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SvcHost` | Registry key that defines services managed by svchost.exe |


## Services (sc)

| Command | Description |
|---------|-------------|
| `sc query` | Show all services |
| `sc query \| findstr /B SERVICE_NAME` | Show only service names |
| `sc query state=all \| findstr /B SERVICE_NAME` | Enumerate all services |
| `sc query \| findstr /R "SERVICE_NAME STATE"` | Show service names and states |
| `sc query <service-name>` | Show status of specific service |
| `sc query <service-name> \| findstr /R "SERVICE_NAME STATE"` | Show service name + state |
| `sc stop <service-name>` | Stop a service |
| `sc start <service-name>` | Start a service |
| `sc query windefend` | Query Windows Defender service |
| `sc queryex type= service` | Print all running services with extended info |


