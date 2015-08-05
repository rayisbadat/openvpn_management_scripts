#!/bin/bash
set -e 
set -u

paste_username=${1}
paste_password=${2}
vpn_username=${3}
vpn_password=${4}

key_val=$(curl -u"${paste_username}:${paste_password}" -s -X POST 'https://paste.opensciencedatacloud.org/documents' -d"$(grep $vpn_username  /etc/openvpn/user_passwd.csv | perl -pe 's/openvpn.//;' -e's|\/user_passwd.csv:|:\t|;')" )
echo $key_val | perl -n -e 'm|.+:\"([^,]+)\"}| && print "https://paste.opensciencedatacloud.org/$1\n"'
