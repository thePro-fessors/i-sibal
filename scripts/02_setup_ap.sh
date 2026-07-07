#!/usr/bin/env bash
set -e

# Ensure dependencies for TUI
if ! command -v whiptail &> /dev/null; then
    sudo apt-get install -y whiptail
fi
if ! command -v iw &> /dev/null; then
    sudo apt-get install -y iw
fi

# Get AP details via TUI
AP_SSID=$(whiptail --inputbox "Enter the SSID (Name) for the Hotspot:" 8 60 "i-Sibal-AP" 3>&1 1>&2 2>&3)
if [ -z "$AP_SSID" ]; then AP_SSID="i-Sibal-AP"; fi

AP_PASS=$(whiptail --passwordbox "Enter the Hotspot password (at least 8 characters):" 8 60 "isibal1234" 3>&1 1>&2 2>&3)
if [ -z "$AP_PASS" ]; then AP_PASS="isibal1234"; fi

# Dynamically detect wireless interfaces
IFACES=$(iw dev | awk '$1=="Interface"{print $2}')
if [ -z "$IFACES" ]; then
    whiptail --msgbox "No wireless interface found. Please check your USB dongle and drivers." 8 60
    exit 1
fi

IFACE_COUNT=$(echo "$IFACES" | wc -w)
if [ "$IFACE_COUNT" -eq 1 ]; then
    WIFI_IFACE=$IFACES
    whiptail --infobox "Interface '$WIFI_IFACE' detected and selected automatically." 8 60
    sleep 2
else
    # Multiple interfaces found, prompt user
    RADIO_OPTIONS=""
    FIRST="ON"
    for i in $IFACES; do
        RADIO_OPTIONS="$RADIO_OPTIONS $i $i $FIRST "
        FIRST="OFF"
    done
    WIFI_IFACE=$(whiptail --title "Select Wireless Interface" --radiolist "Select the interface to use for the AP:" 15 60 4 $RADIO_OPTIONS 3>&1 1>&2 2>&3)
fi

if [ -z "$WIFI_IFACE" ]; then
    echo "Cancelled."
    exit 1
fi

# Prevent conflicts with NetworkManager (e.g., on Bookworm)
if command -v nmcli &> /dev/null; then
    sudo nmcli dev set $WIFI_IFACE managed no || true
fi

# Clean up and add dhcpcd.conf configuration
sudo sed -i "/interface $WIFI_IFACE/,+3d" /etc/dhcpcd.conf 2>/dev/null || true
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF

interface $WIFI_IFACE
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

# Configure hostapd
sudo tee /etc/hostapd/hostapd.conf > /dev/null <<EOF
interface=$WIFI_IFACE
driver=nl80211
ssid=$AP_SSID
hw_mode=g
channel=6
wmm_enabled=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$AP_PASS
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

sudo sed -i 's|^#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd

# Configure dnsmasq
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig 2>/dev/null || true
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
interface=$WIFI_IFACE
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,24h
domain=local
address=/isibal.local/192.168.4.1
EOF

sudo systemctl unmask hostapd
sudo systemctl enable hostapd dnsmasq

whiptail --msgbox "AP Configuration Completed!\nSSID: $AP_SSID\nInterface: $WIFI_IFACE\nPlease reboot the system to apply." 10 60
