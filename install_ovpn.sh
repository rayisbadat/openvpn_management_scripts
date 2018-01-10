#!/bin/bash

export http_proxy="http://cloud-proxy:3128"
export https_proxy="http://cloud-proxy:3128"

#Consts
OPENVPN_PATH='/etc/openvpn'
BIN_PATH="$OPENVPN_PATH/bin"
EASYRSA_PATH="$OPENVPN_PATH/easy-rsa"
VARS_PATH="$EASYRSA_PATH/vars"

#EASY-RSA Vars

    KEY_SIZE=4096
    COUNTRY="US"
    STATE="IL"
    CITY="Chicago"
    ORG="CDIS" 
    EMAIL='support\@datacommons.io'
    KEY_EXPIRE=365


set -e
set -u

prep_env() {

    echo "What is the FQDN for this VPN endpoint? "
    read FQDN
    echo "What is the Cloud/Env/OU/Abrreviation you want to use? "
    read cloud
    #echo "What email address do you want to use? "
    #read email
    

    

    apt-get update
    apt-get -y purge cloud-init
    echo "$FQDN" > /etc/hostname
    hostname $(cat /etc/hostname)

}

install_pkgs() {
    apt-get update; 
    apt-get -y install openvpn bridge-utils libssl-dev openssl zlib1g-dev easy-rsa haveged
}

install_custom_scripts() {

    cd $OPENVPN_PATH

    #pull our openvpn scripts
    git clone -b feat/install_script  git@github.com:LabAdvComp/openvpn_management_scripts.git
    ln -s openvpn_management_scripts bin

}
install_easyrsa() {
    #copy EASYRSA in place
    cp -pr /usr/share/easy-rsa $EASYRSA_PATH
    cp "$OPENVPN_PATH/bin/templates/vars.template" $VARS_PATH

    EASY_RSA_DIR="$EASYRSA_PATH"
    EXTHOST="$FQDN"
    OU="$cloud"
    KEY_NAME="$OU-OpenVPN"

    perl -p -i -e "s|#EASY_RSA_DIR#|$EASY_RSA_DIR|" $VARS_PATH
    perl -p -i -e "s|#EXTHOST#|$EXTHOST|" $VARS_PATH
    perl -p -i -e "s|#KEY_SIZE#|$KEY_SIZE|" $VARS_PATH
    perl -p -i -e "s|#COUNTRY#|$COUNTRY|" $VARS_PATH
    perl -p -i -e "s|#STATE#|$STATE|" $VARS_PATH
    perl -p -i -e "s|#CITY#|$CITY|" $VARS_PATH
    perl -p -i -e "s|#ORG#|$ORG|" $VARS_PATH
    perl -p -i -e "s|#EMAIL#|$EMAIL|" $VARS_PATH
    perl -p -i -e "s|#OU#|$OU|" $VARS_PATH
    perl -p -i -e "s|#KEY_NAME#|$KEY_NAME|" $VARS_PATH
    perl -p -i -e "s|#KEY_EXPIRE#|$KEY_EXPIRE|" $VARS_PATH

}

install_settings() {

    SETTINGS_PATH="$BIN_PATH/settings.sh"
    cp "$OPENVPN_PATH/bin/templates/settings.sh.template" "$SETTINGS_PATH"
    perl -p -i -e "s|#EMAIL#|$EMAIL|" $SETTINGS_PATH
    perl -p -i -e "s|#CLOUD_NAME#|$KEY_NAME|" $SETTINGS_PATH

}

build_PKI() {

    cd $EASYRSA_PATH
    source $VARS_PATH ## execute your new vars file
    echo "This is long"
    ./clean-all  ## Setup the easy-rsa directory (Deletes all keys)
    ./build-dh  ## takes a while consider backgrounding
    ./pkitool --initca ## creates ca cert and key
    ./pkitool --server $EXTHOST ## creates a server cert and key
    openvpn --genkey --secret ta.key


}

    


    prep_env
    #install_pkgs
    #install_custom_scripts
    #install_easyrsa
    install_settings
    #build_PKI
