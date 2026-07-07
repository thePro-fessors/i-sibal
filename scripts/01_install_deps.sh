#!/usr/bin/env bash
set -e

echo "=== [1/4] 의존성 패키지 설치 및 기반 설정 ==="

# 1. 패키지 업데이트 및 설치
echo ">> apt 패키지 업데이트 중..."
sudo apt-get update

echo ">> 필수 패키지 설치 중..."
# AP 관련 패키지
sudo apt-get install -y hostapd dnsmasq iw whiptail

# mDNS 관련 패키지
sudo apt-get install -y avahi-daemon

# GStreamer 및 하드웨어 가속 패키지
sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
  gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

# 빌드 도구 (UxPlay 컴파일용)
sudo apt-get install -y cmake build-essential pkg-config \
  libavahi-compat-libdnssd-dev libssl-dev libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev libplist-dev

# 2. 내장 Wi-Fi 하드웨어 차단
echo ">> 내장 Wi-Fi 비활성화 적용 중..."
CONFIG_TXT="/boot/firmware/config.txt"
# Bullseye 등 하위 호환을 위해 /boot/config.txt 확인
if [ ! -f "$CONFIG_TXT" ] && [ -f "/boot/config.txt" ]; then
    CONFIG_TXT="/boot/config.txt"
fi

if ! grep -q "^dtoverlay=disable-wifi" "$CONFIG_TXT"; then
    echo "dtoverlay=disable-wifi" | sudo tee -a "$CONFIG_TXT" > /dev/null
    echo "내장 Wi-Fi가 비활성화되었습니다. (재부팅 후 적용됨)"
else
    echo "내장 Wi-Fi 비활성화가 이미 적용되어 있습니다."
fi

# 3. 서비스 비활성화 (스크립트 실행 중 충돌 방지)
sudo systemctl stop hostapd dnsmasq || true
sudo systemctl disable hostapd dnsmasq || true

echo "=== 완료 ==="
echo "패키지 설치가 완료되었습니다."
