#!/bin/bash
set -e 
set -u

paste_username=${1}
paste_password=${2}
vpn_username=${3}
vpn_password=${4}

key_val=$(curl -u"${paste_username}:${paste_password}" -s -X POST 'https://paste.opensciencedatacloud.org/documents' -d"$vpn_username,$vpn_password")
echo $key_val | perl -n -e 'm|.+:\"([^,]+)\"}| && print "https://paste.opensciencedatacloud.org/$1\n"'
