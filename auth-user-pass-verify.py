#!/usr/bin/env python
#   Copyright 2015 CDIS
#   Author: Ray Powell rpowell1@uchicago.edu
#  This script assumes that openvpn is santizing inputs like it should. Converting to underscores.
#  It checks the passwd hash table to ensure user supplied password is correct

import os
import sys
import csv
import bcrypt


#Read in the username and password for  ENV variables openvpn uses
username=os.environ['username']
password=os.environ['password']
passwd_csv_file=os.environ['USER_PW_FILE']

#Hash the password
#passwd_hashed=bcrypt.hashpw('$password', bcrypt.gensalt())

f = open(passwd_csv_file,'r')
reader = csv.reader(f)
for row in reader:
    if row[0]==username:
        hashed=row[1]
        try:
            if (bcrypt.hashpw(password, hashed) == hashed):
                f.close()
                sys.exit(0)
            #if you uncomment this it only checks the first instance of the username, which is probally the prefered method
            #else:
            #    f.close()
            #    sys.exit(1)
        except ValueError as e:
            pass

f.close()
sys.exit(1)

        
