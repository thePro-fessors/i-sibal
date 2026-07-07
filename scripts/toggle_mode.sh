#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 [stable | lowlat]"
    echo ""
    echo "  stable : Stable mode (Smooth Playback) - Prioritizes stutter prevention with larger buffers"
    echo "  lowlat : Low-latency mode - Prioritizes A/V sync and response time (May skip frames on Wi-Fi interference)"
    exit 1
fi

MODE=$1

# Stop existing services
sudo systemctl stop i-sibal-stable.service 2>/dev/null || true
sudo systemctl stop i-sibal-lowlat.service 2>/dev/null || true
sudo systemctl disable i-sibal-stable.service 2>/dev/null || true
sudo systemctl disable i-sibal-lowlat.service 2>/dev/null || true

if [ "$MODE" = "stable" ]; then
    echo ">> Switching to Stable (Smooth Playback) mode..."
    sudo systemctl enable i-sibal-stable.service
    sudo systemctl start i-sibal-stable.service
    echo ">> Done! (i-sibal-stable.service is running)"
elif [ "$MODE" = "lowlat" ]; then
    echo ">> Switching to Low-Latency mode..."
    sudo systemctl enable i-sibal-lowlat.service
    sudo systemctl start i-sibal-lowlat.service
    echo ">> Done! (i-sibal-lowlat.service is running)"
else
    echo "Error: Unknown mode. Please use 'stable' or 'lowlat'."
    exit 1
fi
