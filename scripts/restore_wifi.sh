#!/usr/bin/env bash
set -e

echo ">> Stopping all i-Sibal services..."
sudo systemctl stop i-sibal-stable.service i-sibal-lowlat.service hostapd dnsmasq || true
sudo systemctl disable hostapd dnsmasq || true

# Find the interface name from hostapd.conf
WIFI_IFACE=""
if [ -f /etc/hostapd/hostapd.conf ]; then
    WIFI_IFACE=$(grep "^interface=" /etc/hostapd/hostapd.conf | cut -d'=' -f2)
fi

if [ -n "$WIFI_IFACE" ]; then
    echo ">> Restoring interface $WIFI_IFACE to NetworkManager..."
    sudo rm -f /etc/NetworkManager/conf.d/99-isibal-unmanaged.conf || true
    if command -v nmcli &> /dev/null; then
        sudo nmcli dev set $WIFI_IFACE managed yes || true
    fi
    # Clear NAT rules and disable forwarding
    echo ">> Deactivating NAT and cleaning up iptables..."
    sudo iptables -t nat -F 2>/dev/null || true
    sudo iptables -F 2>/dev/null || true
    sudo sysctl -w net.ipv4.ip_forward=0 > /dev/null || true
    
    sudo systemctl reload NetworkManager || true
fi

echo ">> Done. Wi-Fi interface is now managed by NetworkManager."
echo "You can now use nmtui or nmcli to connect to other Wi-Fi networks."
