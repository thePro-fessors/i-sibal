#!/usr/bin/env bash
set -e

echo "=== [4/4] System and Color Tuning Settings ==="

CONFIG_TXT="/boot/firmware/config.txt"
if [ ! -f "$CONFIG_TXT" ] && [ -f "/boot/config.txt" ]; then
    CONFIG_TXT="/boot/config.txt"
fi

echo ">> Forcing HDMI Pixel Encoding (Full RGB 0-255)..."
# Prevents washed-out colors
if ! grep -q "^hdmi_pixel_encoding=2" "$CONFIG_TXT"; then
    echo "hdmi_pixel_encoding=2" | sudo tee -a "$CONFIG_TXT" > /dev/null
    echo "Added hdmi_pixel_encoding=2 to $CONFIG_TXT."
else
    echo "HDMI pixel encoding setting already exists."
fi

echo ">> Creating GStreamer optimization profile..."
sudo tee /etc/profile.d/isibal_gst.sh > /dev/null <<EOF
# i-Sibal GStreamer hardware acceleration force
export GST_PLUGIN_FEATURE_RANK=v4l2slh264dec:MAX
EOF
sudo chmod +x /etc/profile.d/isibal_gst.sh

echo ">> Registering systemd service files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
sudo cp "$PROJECT_DIR"/config/i-sibal-*.service /etc/systemd/system/
sudo systemctl daemon-reload

echo ">> Enabling default stable mode..."
# Enable stable mode by default
sudo "$PROJECT_DIR"/scripts/toggle_mode.sh stable

echo "=== Done ==="
echo "Video tuning and service registration completed. Changes will fully apply after reboot."
