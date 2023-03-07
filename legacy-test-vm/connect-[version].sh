#!/bin/sh

#Copy this file to a folder where an openvpn,key,ca,cert file for a Openvpn connection resides

ssl=0.9.7i
ovpn=207
workdir="$(pwd)"

#echo "$ssl $ovpn $workdir"

/home/maik/vpn/connect-any.sh $ssl $ovpn $workdir

