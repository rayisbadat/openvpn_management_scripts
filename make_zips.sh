#!/bin/bash

if [ "$1" == "" ]
then
    echo "USAGE: $0 vpn_username"
    exit 1
fi

set -u
set -e
user=${1}

#vpn_env=$( hostname | cut -f3 -d- | cut -f1 -d. )
vpn_env=$( hostname | perl -ne 'm|ovpn-([^.]+)\.| && print "$1\n"'  )

cd /tmp
mkdir $user-gdc; 
cp /etc/openvpn/ovpn_files/$user-gdc-${vpn_env}.ovpn /tmp/$user-gdc/; 
cp /etc/openvpn/ovpn_files_seperated/$user-gdc-${vpn_env}-seperated.tgz /tmp/$user-gdc/; 
zip -j $user.zip $user-gdc/*
