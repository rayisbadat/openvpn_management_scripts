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
username=${1}

cd /tmp
mkdir $username-gdc;
mkdir $username-gdc/linux;
cp $KEY_DIR/ovpn_files/$username-$CLOUD_NAME.ovpn /tmp/$username-gdc/; 
cp $KEY_DIR/ovpn_files_seperated/$username-$CLOUD_NAME-seperated.tgz /tmp/$username-gdc/; 
cp $KEY_DIR/ovpn_files_systemd/${username}-${CLOUD_NAME}-systemd.ovpn /tmp/$username-gdc/linux/;
cp $KEY_DIR/ovpn_files_resolvconf/${username}-${CLOUD_NAME}-resolvconf.ovpn /tmp/$username-gdc/linux/;
zip -r $username.zip $username-gdc/*
