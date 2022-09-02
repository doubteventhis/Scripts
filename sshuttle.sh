#!/bin/bash
#
# Use when you have SSH creds to a dual honed host and want to pivot through it to reach an internal network

remote_network="192.168.1.100"		#IP from network you want access to
pivot_machine="10.10.10.10"		#Machine you have SSH access to

user="user"
password="password"
ssh_key="/path/to/key_file"

echo "Opening connection to the $remote_network/24 network through SSH access as $user on $pivot_machine"

PS3="Are you using SSH password or public key authentication? "
options=("Password" "Public Key" "Quit")                                                                              
select opt in "${options[@]}"                                                                                                                                                                                                               
do                                                                                                                                                                                                                                          
    case $opt in 
        "Password")
            echo Using password authentication
	    sshuttle -r $user:$password@$pivot_machine $remote_network/24
	    break
	    ;;
	"Public Key")
            echo Using public key authentication
	    sshuttle -r $user@$pivot_machine $remote_network/24 --ssh-cmd "ssh -i $ssh_key"
	    break
	    ;;
	"Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
