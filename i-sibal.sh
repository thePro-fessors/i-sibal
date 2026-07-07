#!/usr/bin/env bash

# i-Sibal 메인 TUI 관리자

if [ "$EUID" -ne 0 ]; then
  echo "이 도구는 루트 권한으로 실행해야 합니다. sudo ./i-sibal.sh 명령어를 사용하세요."
  exit 1
fi

if ! command -v whiptail &> /dev/null; then
    apt-get install -y whiptail
fi

while true; do
    CHOICE=$(whiptail --title "i-Sibal 관리 메뉴" --menu "원하는 작업을 선택하세요:" 20 60 8 \
        "1" "모드 전환 (안정성 / 저지연)" \
        "2" "AP (핫스팟) 재설정" \
        "3" "네트워크 인터페이스 확인" \
        "4" "UxPlay 로그 모니터링 (실시간)" \
        "5" "서비스 재시작" \
        "6" "시스템 재부팅" \
        "7" "종료" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1)
            MODE=$(whiptail --title "모드 전환" --menu "실행할 모드를 선택하세요:" 15 60 2 \
                "stable" "안정성(부드러운 재생) 모드 (기본)" \
                "lowlat" "저지연(립싱크 우선) 모드" 3>&1 1>&2 2>&3)
            
            if [ -n "$MODE" ]; then
                bash ./scripts/toggle_mode.sh $MODE
                whiptail --msgbox "모드가 '$MODE'로 변경 및 적용되었습니다." 8 60
            fi
            ;;
        2)
            bash ./scripts/02_setup_ap.sh
            ;;
        3)
            IFACES=$(ip -br a | grep -E "^wlan|^wl" || echo "무선 인터페이스 없음")
            whiptail --msgbox "현재 무선 인터페이스 상태:\n\n$IFACES" 15 60
            ;;
        4)
            clear
            echo "======================================"
            echo " 로그 보기를 종료하려면 Ctrl+C 를 누르세요."
            echo "======================================"
            journalctl -u i-sibal-stable.service -u i-sibal-lowlat.service -f || true
            echo ""
            echo "계속하려면 엔터를 누르세요..."
            read
            ;;
        5)
            systemctl restart i-sibal-stable.service 2>/dev/null || true
            systemctl restart i-sibal-lowlat.service 2>/dev/null || true
            whiptail --msgbox "활성화된 미디어 서비스가 재시작되었습니다." 8 60
            ;;
        6)
            if whiptail --yesno "정말 시스템을 재부팅하시겠습니까?" 8 60; then
                reboot
            fi
            ;;
        7)
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
done
