#!/bin/bash
if [ -e /etc/profile.d/99-proxy.sh ]
then
    source /etc/profile.d/99-proxy.sh
fi

if [ -e /etc/openvpn/bin/settings.sh ] && [ -z "$VPN_SETTINGS_LOADED" ]
then
    source /etc/openvpn/bin/settings.sh
fi

if [ "${1}" == "" ]
then
    echo "USAGE: $0 username"
    exit 1
fi

set -e
set -u


create_ots_site_entry() {
    ots_out=$( curl -u "${OTS_USERNAME}:${OTS_API_TOKEN}" -F "secret=$( echo -e $vpn_username\\n${vpn_password} )"  ${OTS_URL_BASE}${OTS_SHARE_URI}  2>/dev/null )
    secret_key=$( echo $ots_out | perl -ne 'm|,"secret_key":"([^"]+)",| && print "$1\n"' )
    vpn_creds_url=${OTS_URL_BASE}${OTS_PRIVATE_URI}/${secret_key}

}
update_password_file() {
    cp $USER_PW_FILE ${USER_PW_FILE}.bak-pwreset
    sed -i "/$vpn_username,\\$/d" ../user_passwd.csv && echo "$vpn_username,$vpn_password" >> $USER_PW_FILE

}

generate_qr_code() {
    uuid=$(uuidgen)
    qrcode_out=/var/www/qrcode/${uuid}.svg
    string=$( python -c "import pyotp; print( pyotp.totp.TOTP('$totp_secret').provisioning_uri('$vpn_username', issuer_name='GDC-OVPN') )" )
    $( python -c "import pyqrcode; pyqrcode.create('$string').svg('${qrcode_out}', scale=8)" )
    vpn_creds_url="https://gdc-ovpn.datacommons.io/$uuid.svg"
}

print_info() {

    #Echo to screen
    echo "Username: ${vpn_username} Password: ${vpn_password}"
    echo "$vpn_creds_url"

}

vpn_username=${1}
totp_secret=$( python -c 'import pyotp; print( pyotp.random_base32() );' )
vpn_password="\$TOTP\$${totp_secret}"

update_password_file
generate_qr_code
#create_ots_site_entry
print_info

