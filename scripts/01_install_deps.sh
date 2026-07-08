#!/usr/bin/env bash
set -e

echo "=== [1/4] Installing Dependencies and Base Settings ==="

# 1. Update and install packages
echo ">> Updating apt packages..."
sudo apt-get update

echo ">> Installing required packages..."
# AP 관련 패키지
sudo apt-get install -y hostapd dnsmasq iw whiptail iptables

# mDNS packages
sudo apt-get install -y avahi-daemon

# GStreamer and hardware acceleration packages
sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
  gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

# Build tools (for compiling UxPlay)
sudo apt-get install -y cmake build-essential pkg-config \
  libavahi-compat-libdnssd-dev libssl-dev libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev libplist-dev

# 2. Disable built-in Wi-Fi
echo ">> Disabling built-in Wi-Fi hardware..."
CONFIG_TXT="/boot/firmware/config.txt"
# Check fallback for Bullseye compatibility
if [ ! -f "$CONFIG_TXT" ] && [ -f "/boot/config.txt" ]; then
    CONFIG_TXT="/boot/config.txt"
fi

if ! grep -q "^dtoverlay=disable-wifi" "$CONFIG_TXT"; then
    echo "dtoverlay=disable-wifi" | sudo tee -a "$CONFIG_TXT" > /dev/null
    echo "Built-in Wi-Fi disabled. (Will take effect after reboot)"
else
    echo "Built-in Wi-Fi is already disabled."
fi

# 3. Disable services (prevent conflicts during setup)
sudo systemctl stop hostapd dnsmasq || true
sudo systemctl disable hostapd dnsmasq || true

echo "=== Done ==="
echo "Package installation completed."
