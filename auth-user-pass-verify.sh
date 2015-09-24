#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu
#  This script assumes that openvpn is santizing inputs like it should. Converting to underscores.
#  It checks the passwd hash table to ensure user supplied password is correct

source /etc/openvpn/bin/settings.sh
/etc/openvpn/bin/auth-user-pass-verify.py

#set -e
#set -u
#
#grep "^$username,$password$" $USER_PW_FILE  &> /dev/null && exit 0
#exit 1
#
#
#hash_passwd() {
#    password_hashed=$( python -c "import bcrypt;print bcrypt.hashpw('$password', bcrypt.gensalt())" )
#}
#
#compare_hashes() {
#    result=$(python -c "import bcrypt;password=\"${password}\";hashed=\"${passwd_hash}\"; print( bcrypt.hashpw(password, hashed) == hashed )")
#    if [ "$result" == "True" ]
#    then
#        #True = 0
#        return 0
#    fi
#    #False = 1
#    return 1
#}
#
#
#passwd_hash=$(grep -E "^$username,\\\$2a\\\$.+" $USER_PW_FILE | cut -f2 -d',' | head -n1)
#
#if compare_hashes
#then
#    exit 0
#else
#    exit 1
#fi
