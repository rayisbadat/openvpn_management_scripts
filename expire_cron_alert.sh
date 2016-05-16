#!/bin/bash
/etc/openvpn/bin/user_status.sh  all | grep expir | ifne mail -s "$(hostname) - VPN Users Expiring Soon" ops@nci-gdc.datacommons.io
