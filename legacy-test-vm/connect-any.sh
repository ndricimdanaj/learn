#!/bin/bash



function rollbackinterfaces {
	echo 'rolling back interface'	
	sudo cp -v  /home/maik/vpn/interfaces.org /etc/network/interfaces
	sudo service network-manager restart
}

#check if there is an interfaces file in the folder
#insert rollback interfaces when the connection is killed.
#the interfaces file is needed for VPNs with a router.
interfacesfile=$(find $workdir -type f -name interfaces -print | head -n 1)
#echo "intfile $interfacesfile"
if [[ -f $interfacesfile ]]; then
	echo "insert rollback interfaces when the connection is killed"
	echo "use $interfacesfile"
	trap rollbackinterfaces EXIT

	echo "integrating new interfaces file"
	sudo cp -v $interfacesfile /etc/network/interfaces
	sudo service network-manager restart
	sleep 5
fi

echo ""
echo ""
echo ""
sslversion=$1
ssl=/opt/openssl/$sslversion/bin/openssl

vpnversion=$2
ovpn=openvpn-$vpnversion

workdir=$3

#echo "$ssl $ovpn $workdir"

if [[ ! -f $ssl ]]; then
	echo "openSSL $ssl does not exist!"
	echo "check /opt/openssl/ and ll /usr/bin/openssl"
	exit 1
fi

if ! command -v $ovpn &>/dev/null
then
	echo "command $ovpn does not exist!"
	echo "check /opt/openvpn/ and ll /usr/bin/openvpn*"
	exit 1
fi

if [[ ! -d $workdir ]]; then
	echo "workdir $workdir does not exist!"
	exit 1
fi

sudo rm /usr/bin/openssl
sudo ln -s $ssl /usr/bin/openssl

echo "----------------SETTINGS----------------"
openssl version
$ovpn --version

cd $workdir
echo "changing to folder with key,cert,ca,ovpn file: $workdir"
cfg=$(find . -name *.ovpn -print | head -n 1)
echo "using cfg file: $cfg"
echo "---------------------------------------"
echo ""

sudo $ovpn --config $cfg



