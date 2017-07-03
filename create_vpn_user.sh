#!/bin/bash
#   Copyright 2017 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu


if [ -e /etc/openvpn/bin/settings.sh ] && [ -z "$VPN_SETTINGS_LOADED" ]
then
    source /etc/openvpn/bin/settings.sh
fi


username=${1}

if [ "$email" == "" ]
then
	email=${2}
else
	email="$username@vpn"
fi

if [ "$username" == "" ]
then
	echo "USAGE: $0 username [email]"
	exit 1
fi
	
set -u
set -e

#Source the settings for EASY RSA
#source $EASYRSA_PATH/vars

#Override exports
export KEY_CN=$username
export KEY_EMAIL=$email
export KEY_ALTNAMES="DNS:${KEY_CN}"

#This create the key's for the road warrior
build-key-batch  $username &>/dev/null

#Backup certs so we can revoke them if ever needed
[ -d  $KEY_DIR/user_certs/ ]  || mkdir  $KEY_DIR/user_certs/
cp $KEY_DIR/$username.crt $KEY_DIR/user_certs/$username.crt-$(date +%F-%T)

#This generates the ovpn file for the road warrior
# aka $0 $username email
#for vpn_env in ${VPN_ENVS}
#do
#    export vpn_type=$(echo $vpn_env | cut -d":" -f1 )
#    export vpn_port=$(echo $vpn_env | cut -d":" -f2 )
#    export EXTPORT=${vpn_port}
#    create_ovpn.sh $KEY_CN $KEY_EMAIL > $KEY_DIR/ovpn_files/${username}-${CLOUD_NAME}-${vpn_type}.ovpn 2> /dev/null
    create_ovpn.sh $KEY_CN $KEY_EMAIL > $KEY_DIR/ovpn_files/${username}-${CLOUD_NAME}.ovpn 2> /dev/null
#done

create_seperated_vpn_zip.sh $KEY_CN &> /dev/null

