#!/usr/bin/env bash
set -e

# TUI를 위한 패키지 확인
if ! command -v whiptail &> /dev/null; then
    sudo apt-get install -y whiptail
fi
if ! command -v iw &> /dev/null; then
    sudo apt-get install -y iw
fi

# TUI 기반 정보 입력
AP_SSID=$(whiptail --inputbox "설정할 핫스팟의 SSID(이름)를 입력하세요:" 8 60 "i-Sibal-AP" 3>&1 1>&2 2>&3)
if [ -z "$AP_SSID" ]; then AP_SSID="i-Sibal-AP"; fi

AP_PASS=$(whiptail --passwordbox "핫스팟의 비밀번호를 8자리 이상 입력하세요:" 8 60 "isibal1234" 3>&1 1>&2 2>&3)
if [ -z "$AP_PASS" ]; then AP_PASS="isibal1234"; fi

# 동적 무선 인터페이스 감지 (wlan0, wlan1 등)
IFACES=$(iw dev | awk '$1=="Interface"{print $2}')
if [ -z "$IFACES" ]; then
    whiptail --msgbox "무선 네트워크 인터페이스를 찾을 수 없습니다. 동글 장착 및 드라이버를 확인하세요." 8 60
    exit 1
fi

IFACE_COUNT=$(echo "$IFACES" | wc -w)
if [ "$IFACE_COUNT" -eq 1 ]; then
    WIFI_IFACE=$IFACES
    whiptail --infobox "인터페이스 '$WIFI_IFACE'를 감지하여 자동으로 선택했습니다." 8 60
    sleep 2
else
    # 여러 개일 경우 (예: 내장 wlan0과 동글 wlan1) TUI로 선택
    RADIO_OPTIONS=""
    FIRST="ON"
    for i in $IFACES; do
        RADIO_OPTIONS="$RADIO_OPTIONS $i $i $FIRST "
        FIRST="OFF"
    done
    WIFI_IFACE=$(whiptail --title "무선 인터페이스 선택" --radiolist "AP로 사용할 무선 인터페이스를 선택하세요:" 15 60 4 $RADIO_OPTIONS 3>&1 1>&2 2>&3)
fi

if [ -z "$WIFI_IFACE" ]; then
    echo "취소되었습니다."
    exit 1
fi

# NetworkManager와 충돌 방지 (Bookworm 환경 등)
if command -v nmcli &> /dev/null; then
    sudo nmcli dev set $WIFI_IFACE managed no || true
fi

# dhcpcd.conf 기존 설정 청소 및 삽입
sudo sed -i "/interface $WIFI_IFACE/,+3d" /etc/dhcpcd.conf 2>/dev/null || true
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF

interface $WIFI_IFACE
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

# hostapd 구성
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

# dnsmasq 구성
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig 2>/dev/null || true
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
interface=$WIFI_IFACE
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,24h
domain=local
address=/isibal.local/192.168.4.1
EOF

sudo systemctl unmask hostapd
sudo systemctl enable hostapd dnsmasq

whiptail --msgbox "AP 구성이 완료되었습니다!\nSSID: $AP_SSID\n인터페이스: $WIFI_IFACE\n시스템을 재부팅해야 적용됩니다." 10 60
