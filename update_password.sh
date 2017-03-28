#!/bin/bash

source /etc/openvpn/bin/settings.sh

username=${1}
password=${2}

set -e
set -u

if [ "$username" == "" ] || [ "$password" == "" ]
then
    echo "USAGE: $0 USERNAME PASSWORD"
    exit 1
fi

safe_password=$( echo $password | perl -pe 's|[^A-Za-z0-9\@\-\_\.\n]|_|g' )
password_hashed=$( python -c "import bcrypt;print bcrypt.hashpw('$safe_password', bcrypt.gensalt())" )

cp $USER_PW_FILE ${USER_PW_FILE}.bak-pwreset
sed -i "/$username,\\$/d" ../user_passwd.csv && echo "$username,$password_hashed" >> $USER_PW_FILE
