#!/bin/bash
if [ -e /etc/profile.d/99-proxy.sh ]
then
    source /etc/profile.d/99-proxy.sh
fi

if [ -e /etc/openvpn/bin/settings.sh ]
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

vpn_username=${1}
vpn_password=$(perl -e 'my $string; my @chars=("A".."Z","a".."z","@","_","-"); while ( not $string =~ /[-_@]/) {
 $string=""; $string .= $chars[rand @chars] for 1..15;} print "$string"')

/etc/openvpn/bin/update_password.sh $vpn_username $vpn_password 
create_ots_site_entry
echo "Username: ${vpn_username} Password: ${vpn_password}"
echo "$vpn_creds_url"
