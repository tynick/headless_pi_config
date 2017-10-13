#!/bin/bash

card_path='/Volumes/boot'


activate_ssh () {
    touch ${card_path}/ssh
}

activate_wifi () {

    read -p "What is the ssid of your network? " ssid
    read -p "What is the ssid of your network? " psk

cat << EOF > ${card_path}/wpa_supplicant.conf
country=US
update_config=1
ctrl_interface=/var/run/wpa_supplicant

network={
    scan_ssid=1
    ssid="${ssid}"
    psk="${psk}"
    }
EOF
done

}

activate_ssh
activate_wifi
