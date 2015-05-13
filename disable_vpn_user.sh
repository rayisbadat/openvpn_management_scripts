#!/bin/bash
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu

set -u
set -e

echo disable > /etc/openvpn/clients.d/$1
