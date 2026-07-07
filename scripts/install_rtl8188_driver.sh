#!/usr/bin/env bash
set -e

echo "=== Installing Realtek RTL8188FTV/FU Driver ==="

echo ">> Installing kernel headers and DKMS..."
sudo apt-get update
sudo apt-get install -y build-essential dkms git
# Try installing headers dynamically matching uname -r, with fallbacks for RPi kernels
sudo apt-get install -y linux-headers-$(uname -r) || sudo apt-get install -y linux-headers-rpi-v8 || sudo apt-get install -y raspberrypi-kernel-headers

echo ">> Cloning driver repository..."
cd "$HOME"
if [ -d "rtl8188fu" ]; then
    sudo rm -rf rtl8188fu
fi
# kelebek333's repo is the most widely maintained driver for this chipset
git clone https://github.com/kelebek333/rtl8188fu

echo ">> Building and installing via DKMS (This may take a few minutes)..."
sudo dkms add ./rtl8188fu
sudo dkms build rtl8188fu/1.0
sudo dkms install rtl8188fu/1.0

echo ">> Copying firmware..."
sudo mkdir -p /lib/firmware/rtlwifi/
sudo cp ./rtl8188fu/firmware/rtl8188fufw.bin /lib/firmware/rtlwifi/

echo ">> Disabling Power Management for stability..."
sudo mkdir -p /etc/modprobe.d
echo "options rtl8188fu rtw_power_mgnt=0 rtw_enusbss=0" | sudo tee /etc/modprobe.d/rtl8188fu.conf > /dev/null

echo ">> Reloading kernel module..."
sudo modprobe rtl8188fu || true

echo "=== Done! ==="
echo "Driver installation completed. You can check if the interface appears with: ip -br a"
