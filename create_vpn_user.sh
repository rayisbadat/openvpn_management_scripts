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

#This create the key's for the road warrior
build-key  $username

#Backup certs so we can revoke them if ever needed
[ -d  $KEY_DIR/user_certs/ ]  || mkdir  $KEY_DIR/user_certs/
cp $KEY_DIR/$username.crt $KEY_DIR/user_certs/$username.crt-$(date +%F-%T)

#This generates the ovpn file for the road warrior
# aka $0 $username email
create_ovpn.sh $KEY_CN $KEY_EMAIL > $KEY_DIR/ovpn_files/${username}-${CLOUD_NAME}.ovpn

#Create the vpn username/password hack
#password=$(pwgen -c -n -y -s 20 1 | perl -pe 's/[^A-z0-9_\-@]//g';) 
password=$(perl -e 'my $string; my @chars=("A".."Z","a".."z","@","_","-"); while ( not $string =~ /[-_@]/) { $string=""; $string .= $chars[rand @chars] for 1..15;} print "$string"')
echo "$username,$password" >> $USER_PW_FILE

