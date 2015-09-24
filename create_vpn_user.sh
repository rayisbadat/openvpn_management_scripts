#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu


source /etc/openvpn/bin/settings.sh

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
create_ovpn.sh $KEY_CN $KEY_EMAIL > $KEY_DIR/ovpn_files/${username}-${CLOUD_NAME}.ovpn 2> /dev/null
create_seperated_vpn_zip.sh $KEY_CN &> /dev/null

#Create the vpn username/password hack
password=$(perl -e 'my $string; my @chars=("A".."Z","a".."z","@","_","-"); while ( not $string =~ /[-_@]/) { $string=""; $string .= $chars[rand @chars] for 1..15;} print "$string"')
password_hashed=$( python -c "import bcrypt;print bcrypt.hashpw('$password', bcrypt.gensalt())" )
echo "$username,$password_hashed" >> $USER_PW_FILE
echo $password

