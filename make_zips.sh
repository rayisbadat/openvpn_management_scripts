#!/bin/bash
user=${1}
mkdir $user-gdc; cp /etc/openvpn/ovpn_files/$user-gdc-staging.ovpn /tmp/$user-gdc/; cp /etc/openvpn/ovpn_files_seperated/$user-gdc-staging-seperated.tgz /tmp/$user-gdc/; zip -j $user.zip $user-gdc/*
