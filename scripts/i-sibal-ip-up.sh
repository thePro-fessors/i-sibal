#!/usr/bin/env bash
# i-Sibal Static IP Configurator

WIFI_IFACE=""
if [ -f /etc/hostapd/hostapd.conf ]; then
    WIFI_IFACE=$(grep "^interface=" /etc/hostapd/hostapd.conf | cut -d'=' -f2)
fi

if [ -n "$WIFI_IFACE" ]; then
    echo "Configuring static IP 192.168.4.1 on $WIFI_IFACE..."
    # Flush existing IPs to prevent conflicts
    ip addr flush dev "$WIFI_IFACE" || true
    # Add static IP
    ip addr add 192.168.4.1/24 dev "$WIFI_IFACE"
    # Ensure interface is up
    ip link set dev "$WIFI_IFACE" up
else
    echo "Error: hostapd.conf not found or interface not set."
    exit 1
fi
