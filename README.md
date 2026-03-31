# headless_pi_config

Configure a freshly imaged Raspberry Pi SD card for headless first boot from macOS.

The script does the following:
- Creates an `ssh` file to enable SSH on first boot
- Writes `wpa_supplicant.conf` so the Pi can join WiFi
- Optionally unmounts the card when complete

## Requirements

- macOS (uses `diskutil`)
- Raspberry Pi boot volume mounted (default path: `/Volumes/boot`)

## Quick start

```bash
git clone git@github.com:tynick/headless_pi_config.git
cd headless_pi_config
chmod +x ./headless_pi_config.sh
./headless_pi_config.sh
```

The script prompts for WiFi SSID and password if not provided as flags.

## Usage

```bash
./headless_pi_config.sh [options]
```

Options:
- `-p, --path <mount-path>`: boot volume path (default: `/Volumes/boot`)
- `-c, --country <code>`: WiFi country code (default: `US`)
- `-s, --ssid <name>`: WiFi SSID (optional, will prompt if omitted)
- `-k, --psk <password>`: WiFi password (optional, will prompt if omitted)
- `--no-eject`: do not unmount card at the end
- `-h, --help`: print help text

## Examples

Use defaults and interactive prompts:

```bash
./headless_pi_config.sh
```

Custom mount path and country:

```bash
./headless_pi_config.sh --path /Volumes/bootfs --country GB
```

Non-interactive run:

```bash
./headless_pi_config.sh --ssid "MyNetwork" --psk "MyPassword"
```
