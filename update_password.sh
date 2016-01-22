#!/bin/bash

source /etc/openvpn/bin/settings.sh

username=${1}
password=${2}

set -e
set -x

if [ "$username" == "" ] || [ "$password" == "" ]
then
    echo "USAGE: $0 USERNAME PASSWORD"
    exit 1
fi

password_hashed=$( python -c "import bcrypt;print bcrypt.hashpw('$password', bcrypt.gensalt())" )
#perl -p -i.bak-pwreset -e "s|^($username),(.+)$|\$1,$password_hashed|" $USER_PW_FILE

cp $USER_PW_FILE ${USER_PW_FILE}.bak-pwreset
sed -i "/$username,\\$/d" ../user_passwd.csv && echo "$username,$password_hashed" >> $USER_PW_FILE

