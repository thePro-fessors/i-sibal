#!/usr/bin/env bash

# i-Sibal Main TUI Manager

if [ "$EUID" -ne 0 ]; then
  echo "This tool must be run with root privileges. Please use: sudo ./i-sibal.sh"
  exit 1
fi

if ! command -v whiptail &> /dev/null; then
    apt-get install -y whiptail
fi

while true; do
    CHOICE=$(whiptail --title "i-Sibal Management Menu" --menu "Select an option:" 20 60 8 \
        "1" "Switch Mode (Stable / Low-Latency)" \
        "2" "Reconfigure AP (Hotspot)" \
        "3" "Check Network Interfaces" \
        "4" "Monitor UxPlay Logs (Real-time)" \
        "5" "Restart Services" \
        "6" "Reboot System" \
        "7" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1)
            MODE=$(whiptail --title "Switch Mode" --menu "Select the execution mode:" 15 60 2 \
                "stable" "Stable Mode (Smooth Playback, Default)" \
                "lowlat" "Low-Latency Mode (Prioritizes A/V Sync)" 3>&1 1>&2 2>&3)
            
            if [ -n "$MODE" ]; then
                bash ./scripts/toggle_mode.sh $MODE
                whiptail --msgbox "Mode has been changed and applied to '$MODE'." 8 60
            fi
            ;;
        2)
            bash ./scripts/02_setup_ap.sh
            ;;
        3)
            IFACES=$(ip -br a | grep -E "^wlan|^wl" || echo "No wireless interfaces found")
            whiptail --msgbox "Current Wireless Interface Status:\n\n$IFACES" 15 60
            ;;
        4)
            clear
            echo "======================================"
            echo " Press Ctrl+C to stop viewing logs."
            echo "======================================"
            journalctl -u i-sibal-stable.service -u i-sibal-lowlat.service -f || true
            echo ""
            echo "Press Enter to continue..."
            read
            ;;
        5)
            systemctl restart i-sibal-stable.service 2>/dev/null || true
            systemctl restart i-sibal-lowlat.service 2>/dev/null || true
            whiptail --msgbox "Active media services have been restarted." 8 60
            ;;
        6)
            if whiptail --yesno "Are you sure you want to reboot the system?" 8 60; then
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
