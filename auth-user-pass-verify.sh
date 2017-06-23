#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu
#  This script assumes that openvpn is santizing inputs like it should. Converting to underscores.
#  It checks the passwd hash table to ensure user supplied password is correct

source /etc/openvpn/bin/settings.sh
/etc/openvpn/bin/auth-user-pass-verify.py
