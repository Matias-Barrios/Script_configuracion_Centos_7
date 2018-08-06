#/bin/bash

function Parse_value() {
    if [[ -z $1 ]] || [[ -z $2 ]]
    then
        echo ""
        return
    fi

    if [[ "$1" =~ '=' ]]
    then
        echo ""
        return
    fi

    echo "$2" | grep -E "^${1}[ ]*=" | tail -1 | sed -E "s/^([^=]+)(=)([ ]*)([^ ]+)([ ]*)/\4/g"

}

function Trimm() {
    if [[ ! -z /dev/stdin ]]
    then
        echo "$( cat )" | sed 's/^ *//g; s/ *$//g'
    else
        echo "$1" | sed 's/^ *//g; s/ *$//g'
    fi
}



function Setear_IP_Hostname_DNS () {

    if [ $# -eq 5 ]
    then

        echo ""
        echo "Taking the backup and Changing the hostname from $(hostname) to $1 ..."

        sed -i.bk "s/$(hostname)/$1/g" /etc/sysconfig/network

        echo ""
        echo "Backing up & Assigning the Static IP ..."
        echo ""

        cp /etc/sysconfig/network-scripts/ifcfg-$2 /etc/sysconfig/network-scripts/$2.bk

        echo "DEVICE=$2"                > /etc/sysconfig/network-scripts/ifcfg-$2
        echo "BOOTPROTO=static"         >> /etc/sysconfig/network-scripts/ifcfg-$2
        echo "IPADDR=$3.$4"             >> /etc/sysconfig/network-scripts/ifcfg-$2
        echo "NETMASK=255.255.255.0"    >> /etc/sysconfig/network-scripts/ifcfg-$2
        echo "GATEWAY=$3.$5"            >> /etc/sysconfig/network-scripts/ifcfg-$2
        echo "ONBOOT=yes"               >> /etc/sysconfig/network-scripts/ifcfg-$2

        echo "Changing the dns ..."
        echo ""

        sed -i.bk "s/nameserver.*/nameserver $3.$5/" /etc/resolv.conf

        echo "Adding $1 as hostname to the /etc/hosts file .."
        echo ""

        sed -i.bk "/$(hostname)$/d" /etc/hosts
        echo "$3.$4 $1" >> /etc/hosts

        echo "Restarting the Network Service, Please connect it using the new IP Address if you are using ssh ..."

        systemctl restart network

    else

        echo "Usage: ip.sh <hostname> <interface> <baseip> <ipaddress> <gateway/dns>"
        echo "Example: ip.sh testname eth0 10.10.10 41 1"

    fi

}
