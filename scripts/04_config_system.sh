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

echo "=== Done ==="
echo "Video tuning completed. Changes will fully apply after reboot."
