#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu


source /etc/openvpn/bin/settings.sh 
#Source the settings for EASY RSA
source $EASYRSA_PATH/vars &>/dev/null

cmd=${1}

if [ -z "$cmd" ]
then
    echo "USAGE: $0 [all|active|disabled|revoked]"
    exit 1
fi

set -u
set -e

crl=$(tempfile)
make_crl(){
    cat ${KEY_PATH}/ca.crt  ${KEY_PATH}/crl.pem  > $crl
}


is_active_crt(){
    openssl verify -crl_check -CAfile $crl $crt &>/dev/null
    if [ $?  -eq 0 ]
    then
        echo true
    else
        echo false
    fi

}

check_for_revoked(){
    for crt in $( ls ${KEY_PATH}/*.crt )
    do
        echo $crt
         is_active_crt && echo "moo"
    done

}

find_email() {
    #username=$( openssl x509 -in ../easy-rsa/keys/jporter.crt -text | grep Subject | grep CN | perl -ne 'm|CN=([^/]+)/| && print "$1\n"' )
    openssl x509 -in $crt -text | grep Subject | grep CN | perl -ne 'm|emailAddress=\s*(\S+)| && print "$1\n"'
}

check_status(){

    for vpn_user in $(cut -f1 -d, $USER_PW_FILE)
    do
        crt="${KEY_PATH}/${vpn_user}.crt"
        email=$( find_email )

        if [ "$(is_active_crt)" == "true" ]
        then
            if [ -e /etc/openvpn/clients.d/$vpn_user ]
            then
                if [ $( grep disable /etc/openvpn/clients.d/$vpn_user ) ]
                then
                    echo $vpn_user,$email,disabled
                else
                    echo $vpn_user,$email,active
                fi
            else
                echo $vpn_user,$email,active
            fi
        else
            echo $vpn_user,$email,revoked
        fi
   done

}


make_crl
if [ "$cmd" == "all" ]
then
    check_status
else
    check_status | grep -E ",$cmd$"
fi
