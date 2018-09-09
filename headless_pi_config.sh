#!/bin/bash
# tynick.com
# tested on Mac OS 10.13

card_path='/Volumes/boot'

# make sure card is mounted.
check_card () {
    df -h | grep -q ${card_path}
    status=${?}
    if [[ ${status} -ne 0 ]]; then
        echo -e "\nUnable to find sd card mounted at ${card_path}\nExiting.\n"
        exit 1
    else
        echo -m "\nSD card found at ${card_path}\n."
    fi
}

# touch file to activate ssh access.
activate_ssh () {
    echo -e "\nConfiguring SSH access.\n"
    touch ${card_path}/ssh
    echo -e "\nSSH access has been configured.\n"
}

# add and populate wpa_supplicant.conf.
activate_wifi () {
    echo -e "\nConfiguring WiFi access.\n"

    read -p "Enter ssid of your network: " ssid
    read -p "Enter the password for ${ssid}: " psk

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

# attempt to eject card. warn user if it is in use.
eject_card () {
    sd_card=$(df -h | grep /Volumes/boot | awk '{ print $1 }')
    echo -e "\nEjecting ${sd_card}\n"
    diskutil unmount ${sd_card}
    status=${?}
    if [[ ${status} -ne 0 ]]; then
        echo -e "\nUnable to eject sd card mounted at ${card_path}\n"
        echo -e "\nSomething is using ${card_path}. Please manually eject.\n"
        exit 1
    else
        echo -e "\n${card_path} ejected. You can now remove your SD card.\n"
    fi
}

# run everything
main () {
    check_card
    activate_ssh
    activate_wifi
    eject_card
}

main
