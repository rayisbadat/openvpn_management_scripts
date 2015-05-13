#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu

source /etc/openvpn/bin/settings.sh

set -e
set -u

grep "^$username,$password$" $USER_PW_FILE  &> /dev/null && exit 0
exit 1
