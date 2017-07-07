#!/bin/bash
#   Copyright 2017 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu

if [ -e /etc/openvpn/bin/settings.sh ] && [ -z "$VPN_SETTINGS_LOADED" ]
then
    source /etc/openvpn/bin/settings.sh
fi

if [ "$1" == "" ]
then
    echo "USAGE: $0 vpn_username"
    exit 1
fi

set -u
set -e
user=${1}

cd /tmp
mkdir $user-gdc; 
cp /etc/openvpn/ovpn_files/$user-$CLOUD_NAME.ovpn /tmp/$user-gdc/; 
cp /etc/openvpn/ovpn_files_seperated/$user-$CLOUD_NAME-seperated.tgz /tmp/$user-gdc/; 
zip -j $user.zip $user-gdc/*
