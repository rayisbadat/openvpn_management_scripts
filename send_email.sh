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

if [ -e /etc/openvpn/bin/settings.sh ] && [ -z "$VPN_SETTINGS_LOADED" ]
then
    source /etc/openvpn/bin/settings.sh
fi


set -e
set -u



create_vpn_user() {
    #./create_vpn_user.sh
    #USAGE: ./create_vpn_user.sh username [email]
    #vpn_password=$($VPN_BIN_ROOT/create_vpn_user.sh "$vpn_username" "$vpn_email")
    $VPN_BIN_ROOT/create_vpn_user.sh "$vpn_username" "$vpn_email"
}
create_vpn_zip() {
    $VPN_BIN_ROOT/make_zips.sh "$vpn_username"
}
set_vpn_totp_secret() {
    vpn_totp_qrcode=$( $VPN_BIN_ROOT/reset_totp_token.sh "$vpn_username" | tail -n1 )
}
vpn_user_exists() {
    grep -E "^$vpn_username," ${VPN_USER_CSV} &>/dev/null
    return $?
}

create_ots_site_entry() {
    ots_out=$( curl -u "${OTS_USERNAME}:${OTS_API_TOKEN}" -F "secret=$( echo -e $vpn_username\\n${vpn_password} )"  ${OTS_URL_BASE}${OTS_SHARE_URI} )
    secret_key=$( echo $ots_out | perl -ne 'm|,"secret_key":"([^"]+)",| && print "$1\n"' )
    vpn_creds_url=${OTS_URL_BASE}${OTS_PRIVATE_URI}/${secret_key}

}
send_welcome_letter_ots() {

    #export VPN_CREDS_URL=${vpn_creds_url}
    export VPN_CREDS_URL="https://foo.bar/test"
    cat $VPN_BIN_ROOT/templates/gdc_creds_template.txt | envsubst | mutt $vpn_email -e "set realname='$EMAIL'"  -s "GDC VPN Configuration Files: $CLOUD_NAME" -a/tmp/$vpn_username.zip $VPN_FILE_ATTACHMENTS
}

send_welcome_letter_png() {

    #export VPN_CREDS_URL=${vpn_creds_url}
    export VPN_CREDS_URL=${vpn_totp_qrcode}
    cat $VPN_BIN_ROOT/templates/gdc_creds_template.txt | envsubst | mutt $vpn_email -e "set realname='$EMAIL'"  -s "GDC VPN Configuration Files: $CLOUD_NAME" -a/tmp/$vpn_username.zip $VPN_FILE_ATTACHMENTS
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
    set_vpn_totp_secret
    send_welcome_letter_png
    #create_ots_site_entry
    #send_welcome_letter_ots

done < ${FILENAME}
