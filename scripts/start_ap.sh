#!/usr/bin/env bash
set -e

# Find interface
WIFI_IFACE=""
if [ -f /etc/hostapd/hostapd.conf ]; then
    WIFI_IFACE=$(grep "^interface=" /etc/hostapd/hostapd.conf | cut -d'=' -f2)
fi

if [ -z "$WIFI_IFACE" ]; then
    echo "Error: AP is not configured yet. Please run 02_setup_ap.sh first."
    exit 1
fi

echo ">> Hiding interface $WIFI_IFACE from NetworkManager..."
if command -v nmcli &> /dev/null; then
    sudo nmcli dev set $WIFI_IFACE managed no || true
    sudo mkdir -p /etc/NetworkManager/conf.d
    echo -e "[keyfile]\nunmanaged-devices=interface-name:$WIFI_IFACE" | sudo tee /etc/NetworkManager/conf.d/99-isibal-unmanaged.conf > /dev/null
    sudo systemctl reload NetworkManager || true
fi

echo ">> Assigning static IP 192.168.4.1 to interface..."
if [ -f /usr/local/bin/i-sibal-ip-up.sh ]; then
    sudo /usr/local/bin/i-sibal-ip-up.sh || true
else
    # Fallback to local copy if not installed
    sudo bash "$SCRIPT_DIR/i-sibal-ip-up.sh" || true
fi

echo ">> Starting AP (hostapd) and DHCP (dnsmasq) services..."
sudo systemctl unmask hostapd || true
sudo systemctl enable hostapd dnsmasq || true
sudo systemctl start hostapd dnsmasq

# Start the stable service by default if no service is running
if ! systemctl is-active --quiet i-sibal-stable.service && ! systemctl is-active --quiet i-sibal-lowlat.service; then
    echo ">> Starting default stable AirPlay service..."
    sudo systemctl enable i-sibal-stable.service || true
    sudo systemctl start i-sibal-stable.service
fi

echo ">> Done. AP is running and AirPlay is active."
