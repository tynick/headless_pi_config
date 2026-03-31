#!/bin/bash

set -euo pipefail

card_path="/Volumes/boot"
country="US"
ssid=""
psk=""
skip_eject="false"

usage() {
    cat <<'EOF'
Usage: ./headless_pi_config.sh [options]

Options:
  -p, --path <mount-path>   Path where the boot volume is mounted (default: /Volumes/boot)
  -c, --country <code>      WiFi country code (default: US)
  -s, --ssid <name>         WiFi SSID (prompted if omitted)
  -k, --psk <password>      WiFi password (prompted if omitted)
      --no-eject            Do not unmount card after configuration
  -h, --help                Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            card_path="$2"
            shift 2
            ;;
        -c|--country)
            country="$2"
            shift 2
            ;;
        -s|--ssid)
            ssid="$2"
            shift 2
            ;;
        -k|--psk)
            psk="$2"
            shift 2
            ;;
        --no-eject)
            skip_eject="true"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

check_requirements() {
    if ! command -v diskutil >/dev/null 2>&1; then
        echo "This script is intended for macOS and requires diskutil."
        exit 1
    fi
}

check_card() {
    if [[ ! -d "$card_path" ]]; then
        echo
        echo "Mount path does not exist: $card_path"
        echo
        exit 1
    fi

    if ! mount | grep -Fq " on ${card_path} "; then
        echo
        echo "Unable to find mounted SD card at $card_path"
        echo "Verify the card is inserted and mounted, then try again."
        echo
        exit 1
    fi

    echo
    echo "SD card found at $card_path"
    echo
}

activate_ssh() {
    echo
    echo "Configuring SSH access."
    touch "${card_path}/ssh"
    echo "SSH access has been configured."
    echo
}

prompt_for_wifi() {
    if [[ -z "$ssid" ]]; then
        read -r -p "Enter SSID of your network: " ssid
    fi

    if [[ -z "$psk" ]]; then
        read -r -s -p "Enter password for ${ssid}: " psk
        echo
    fi
}

activate_wifi() {
    prompt_for_wifi

    if [[ -z "$ssid" || -z "$psk" ]]; then
        echo "SSID and password are required."
        exit 1
    fi

    echo
    echo "Configuring WiFi access for SSID: $ssid"

    cat <<EOF > "${card_path}/wpa_supplicant.conf"
country=${country}
update_config=1
ctrl_interface=/var/run/wpa_supplicant

network={
    scan_ssid=1
    ssid="${ssid}"
    psk="${psk}"
}
EOF

    echo "WiFi configuration has been written."
    echo
}

eject_card() {
    local device
    device="$(df "$card_path" | awk 'NR==2 { print $1 }')"

    if [[ -z "$device" ]]; then
        echo "Unable to determine mounted device for $card_path."
        echo "Please eject the card manually."
        exit 1
    fi

    echo
    echo "Unmounting $device"

    if ! diskutil unmount "$device" >/dev/null; then
        echo
        echo "Unable to unmount card mounted at $card_path."
        echo "Something may still be using it. Please eject manually."
        echo
        exit 1
    fi

    echo "$card_path has been unmounted. You can now remove your SD card."
    echo
}

main() {
    check_requirements
    check_card
    activate_ssh
    activate_wifi

    if [[ "$skip_eject" != "true" ]]; then
        eject_card
    fi
}

main
