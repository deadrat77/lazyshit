#!/bin/bash

Green='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

check_internet() {
    echo -n "Checking internet connection...  
    "
    if ping -c 1 google.com &> /dev/null; then
        echo -e "Connected!
        "
    else
        echo -e "Not connected. Please check your internet connection. :("
        exit 1
    fi
}
#############################
#############################
#############################
check_free_space() {
    threshold_gb=15
    # Get the available disk space in gigabytes
    free_space=$(df -BG --output=avail / | tail -n 1 | tr -d 'G')

    echo -n "Checking free disk space...
    "
    if ((free_space >= threshold_gb)); then
        echo -e "You have more than $threshold_gb GB of free space.
        "
    else
        echo -e "You have less than $threshold_gb GB of free space. Please free up some space. :( "
        exit 1
    fi
}
#############################
#############################
#############################
function DNS {
    read -p "Enter a domain name : " domain_name
    read -p "Enter a domain sufix : " domain_sufix    
    echo "

    installing bind9...
    "
apt update -y && apt upgrade -y
apt install bind9 bind9utils bind9-doc -y
ifconfig lo down
ip link set dev lo down
interface=$(ip a | awk '/^[0-9]+: [a-zA-Z0-9]+:/ {if (++count == 2) {gsub(/:/,"",$2); print $2; exit}}')
ipaddress= ifconfig | grep 'inet ' | awk '{print $2}'
digits=$(ip -o addr show dev "$interface" | awk '$3 == "inet" {print $4}' | sed -r 's!/.*!!; s!.*\.!!')

#############################
########## CONFIGS ############
#############################

named_conf_local_config="
zone "$domain_name.$domain_sufix" IN {
        type master;
        file "/etc/bind/zones/db.$domain_name.$domain_sufix";
};

zone "130.1.192.in-addr.arpa" IN {
        type master;
        file "/etc/bind/zones/db.$domain_name.$domain_sufix.rev";
};
"


named_conf_options_config="
acl trusted{
    localhost;
};

options {
        directory "/var/cache/bind";
        allow-query {any;};
        forwarders { 8.8.8.8; 4.4.4.4; };
        recursion yes;
        dnssec-validation no;
        allow-recursion { any; };
};"


echo -e "${Green}creating zones directory and files...
     "
mkdir /etc/bind/zones
touch /etc/bind/zones/$domain_name.$domain_sufix
forward_zone_file="/etc/bind/zones/$domain_name.$domain_sufix"
touch /etc/bind/zones/rev.$domain_name.$domain_sufix
reverse_zone_file="rev.$domain_name.$domain_sufix"
echo -e "${Green}configuring zone files...
    "
ifconfig lo down
ip link set dev lo down
#############################
#############################
    forward_zone_config="
;
$TTL    604800
@       IN      SOA     server.$domain_name.$domain_sufix. root.server.$domain_name.$domain_sufix. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      server.$domain_name.$domain_sufix.
@       IN      A       $ipaddress
server  IN      A       $ipaddress

@       IN      NS      ns1.$domain_name.$domain_sufix.
@       IN      A       $ipaddress
ns1     IN      A       $ipaddress  
"

cat <<EOF > "$forward_zone_file"
$forward_zone_config
EOF
#############################
#############################
reverse_zone_config="
$TTL    604800
@       IN      SOA     server.$domain_name.$domain_sufix. root.server.$domain_name.$domain_sufix. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      PTR     $domain_name.$domain_sufix.
@       IN      NS      server.$domain_name.$domain_sufix.
$digits IN      PTR     server.$domain_name.$domain_sufix.
server  IN      A       $ipaddress
host    IN      A       $ipaddress


@       IN      NS      ns1.$domain_name.$domain_sufix.
ns1     IN      A       $ipaddress
$digits IN      PTR     ns1.$domain_name.$domain_sufix.
"

cat <<EOF > "$reverse_zone_file"
$reverse_zone_config
EOF
#############################
#############################
ifconfig lo up
sudo ip link set dev lo up
service bind9 restart
}


#############################
#############################
#############################
function Mail {
    echo "test mail"
}
#############################
#############################
#############################
function Ldap {
    echo "test ldap"
}
#############################
#############################
#############################
function Proxy {

    echo "test proxy"
}
#############################
#############################
#############################
function SambaAD {

    echo "test samba"
}
#############################
#############################
#############################
function menu {
options=("setup Bind9" "setup PostFix + Dovecot (in progress)" "setup Slapd" "Setup Squid (in progress)" "Setup SambaAD (in progress)" "Quit")
select choice in "${options[@]}"; do
    case $REPLY in
        1)
            DNS
            ;;
        2)
            Mail
            ;;
        3)
            Ldap
            ;;
        4)
            Proxy
            ;;
        5)
            SambaAD
            ;;

        6)
            echo -e "
Exiting the menu"
            break
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
done
}
#############################
#############################
#############################

function banner {
purple='\033[1;35m'
NC='\033[0m'
echo -e "$purple
▄▄▌   ▄▄▄· ·▄▄▄▄• ▄· ▄▌     ▄▄▄· ·▄▄▄▄  • ▌ ▄ ·. ▪   ▐ ▄ 
██•  ▐█ ▀█ ▪▀·.█▌▐█▪██▌    ▐█ ▀█ ██▪ ██ ·██ ▐███▪██ •█▌▐█
██▪  ▄█▀▀█ ▄█▀▀▀•▐█▌▐█▪    ▄█▀▀█ ▐█· ▐█▌▐█ ▌▐▌▐█·▐█·▐█▐▐▌
▐█▌▐▌▐█ ▪▐▌█▌▪▄█▀ ▐█▀·.    ▐█ ▪▐▌██. ██ ██ ██▌▐█▌▐█▌██▐█▌
.▀▀▀  ▀  ▀ ·▀▀▀ •  ▀ •      ▀  ▀ ▀▀▀▀▀• ▀▀  █▪▀▀▀▀▀▀▀▀ █▪
$NC
                    LazySetup v0.0.1
                                        by: $purple M0thy $NC

"
}
#############################
#############################
#############################
echo "CHECKS: 
"
sleep 1
check_internet
sleep 1
check_free_space
sleep 2
banner
menu 
