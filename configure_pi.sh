#!/bin/bash

# needs error handling in case there is nothing there
card_path='/Volumes/boot'


activate_ssh () {
    touch ${card_path}/ssh
    echo -e "\nSSH has been configured.\n"
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

echo -e "\nWiFi network ${ssid} has been configured.\n"

}

# needs error handling
eject_card () {
     sd_card=$(df -h | grep /Volumes/boot | awk '{ print $1 }')
     echo -e "\nEjecting ${sd_card}\n"
     diskutil unmount ${sd_card}
     echo -e "\nDone. You can now remove your SD card.\n"
}

activate_ssh
activate_wifi
eject_card
