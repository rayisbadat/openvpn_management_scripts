#!/bin/bash

if [ "${1}" == "" ] 
then
    echo "USAGE: $0 path_to_csv"
    echo -e "CSV FORMAT:\n\t\tfull_name_1, email1\n\t\tfull_name2,email2"
    exit 1
fi

FILENAME=${1}
if [ ! -e "$1" ]
then
    "ERROR: $FILENAME does not exist"
    exit 1
fi

if [ -e /etc/profile.d/99-proxy.sh ]
then
    source /etc/profile.d/99-proxy.sh
fi


set -e
set -u

#Set vars and constants
export REPLYTO=support@opensciencedatacloud.org
export EMAIL=support@opensciencedatacloud.org
export PASTE_SITE_USERNAME=$(cat /etc/openvpn/uat_paste_username)
export PASTE_SITE_PASSWORD=$(cat /etc/openvpn/uat_paste_password)
export VPN_BIN_ROOT="/etc/openvpn/bin"
export VPN_USER_CSV="/etc/openvpn/user_passwd.csv"
export VPN_FILE_ATTACHMENTS="-a$VPN_BIN_ROOT/OpenVPN_for_GDC_Installation_Guide_26OCT.pdf"


create_vpn_user() {
    #./create_vpn_user.sh
    #USAGE: ./create_vpn_user.sh username [email]
    vpn_password=$($VPN_BIN_ROOT/create_vpn_user.sh "$vpn_username" "$vpn_email")
}
create_vpn_zip() {
    $VPN_BIN_ROOT/make_zips.sh "$vpn_username"
}
vpn_user_exists() {
    grep -E "^$vpn_username," ${VPN_USER_CSV} &>/dev/null
    return $?
}

create_paste_site_entry() {
    #push_to_paste.sh
    export vpn_creds_url=$($VPN_BIN_ROOT/push_to_paste.sh "$PASTE_SITE_USERNAME" "$PASTE_SITE_PASSWORD" "$vpn_username" "$vpn_password")
}
send_welcome_letter() {
    cat $VPN_BIN_ROOT/templates/email_paste_template.txt | envsubst | mutt $vpn_email -e "set realname='$EMAIL'" -s "Welcome to the Open Science Data cloud (OSDC) private 'paste' site."
    echo "$vpn_creds_url" | mutt $vpn_email -e "set realname='$EMAIL'"  -s 'GDC OpenVPN login username and password url'
    cat $VPN_BIN_ROOT/templates/email_config_files_template.txt | envsubst | mutt $vpn_email -e "set realname='$EMAIL'"  -s "GDC VPN Configuration Files" -a/tmp/$vpn_username.zip $VPN_FILE_ATTACHMENTS
}


while read line
do 
    #Unset variable to prevent oops
    unset vpn_username
    unset vpn_email
    unset vpn_password
    unset vpn_creds_url


    #Send the current user to stderr incase we abort to error
    echo "$line" 1>&2

    #CSV should only have two fields
    vpn_username=$(echo $line | cut -f1 -d"," | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]' )
    vpn_email=$(echo $line | cut -f2 -d",")

    #Skip the header
    if [ "$vpn_username" == "Name" ] || [ "$vpn_email" == "E-mail" ]
    then
        continue
    fi 
   
    if vpn_user_exists
    then
        echo "$vpn_username exists skipping"
        continue
    fi

    create_vpn_user
    create_vpn_zip
    create_paste_site_entry
#    send_welcome_letter
    


done < ${FILENAME}
