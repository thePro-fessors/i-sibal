#!/usr/bin/env bash
set -e

echo "=== [4/4] 시스템 및 색상 튜닝 설정 ==="

CONFIG_TXT="/boot/firmware/config.txt"
if [ ! -f "$CONFIG_TXT" ] && [ -f "/boot/config.txt" ]; then
    CONFIG_TXT="/boot/config.txt"
fi

echo ">> HDMI 색상 설정 강제 (Full RGB 0-255)..."
# 색이 물빠져보이는 현상 방지
if ! grep -q "^hdmi_pixel_encoding=2" "$CONFIG_TXT"; then
    echo "hdmi_pixel_encoding=2" | sudo tee -a "$CONFIG_TXT" > /dev/null
    echo "hdmi_pixel_encoding=2 가 $CONFIG_TXT 에 추가되었습니다."
else
    echo "HDMI 픽셀 인코딩 설정이 이미 존재합니다."
fi

echo ">> GStreamer 최적화 환경변수 프로파일 생성..."
sudo tee /etc/profile.d/isibal_gst.sh > /dev/null <<EOF
# i-Sibal GStreamer 하드웨어 가속 강제
export GST_PLUGIN_FEATURE_RANK=v4l2slh264dec:MAX
EOF
sudo chmod +x /etc/profile.d/isibal_gst.sh

echo "=== 완료 ==="
echo "비디오 튜닝이 완료되었습니다. 변경사항은 재부팅 후 완벽히 적용됩니다."
