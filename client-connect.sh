#!/bin/bash

if [ -e /etc/openvpn/bin/settings.sh ] && [ -z "$VPN_SETTINGS_LOADED" ]
then
    source /etc/openvpn/bin/settings.sh
fi

set -e
set -u

custom_user_config="${1}"

# first, strip underscores
CLEAN=${username//_/}
# next, replace spaces with underscores
CLEAN=${CLEAN// /_}
# now, clean out anything that's not alphanumeric or an underscore
CLEAN=${CLEAN//[^a-zA-Z0-9_]/}
# finally, lowercase with TR
CLEAN=`echo -n $CLEAN | tr A-Z a-z`
#export username="${CLEAN}"

custom_config_file="${OPENVPN_MY_BIN}/environments/${CLEAN}"

if [ -e $custom_config_file ]
then
    cat ${custom_config_file} >> $custom_user_config
fi

exit 0
