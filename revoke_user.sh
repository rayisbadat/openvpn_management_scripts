#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu

set -u
set -e

source /etc/openvpn/bin/settings.sh

username=${1}


#Source the settings for EASY RSA
source $EASYRSA_PATH/vars

#Override exports
export KEY_CN=$username

revoke-full $username

sed -i "/${username},/d" $USER_PW_FILE
