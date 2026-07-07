#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "사용법: $0 [stable | lowlat]"
    echo ""
    echo "  stable : 안정성(부드러운 재생) 모드 - 넉넉한 버퍼로 끊김 방지 최우선"
    echo "  lowlat : 저지연 모드 - 립싱크 및 반응속도 최우선 (Wi-Fi 혼섭 시 스킵 가능성 있음)"
    exit 1
fi

MODE=$1

# 기존 서비스 멈춤
sudo systemctl stop i-sibal-stable.service 2>/dev/null || true
sudo systemctl stop i-sibal-lowlat.service 2>/dev/null || true
sudo systemctl disable i-sibal-stable.service 2>/dev/null || true
sudo systemctl disable i-sibal-lowlat.service 2>/dev/null || true

if [ "$MODE" = "stable" ]; then
    echo ">> 안정성(부드러운 재생) 모드로 전환합니다..."
    sudo systemctl enable i-sibal-stable.service
    sudo systemctl start i-sibal-stable.service
    echo ">> 완료! (i-sibal-stable.service 동작 중)"
elif [ "$MODE" = "lowlat" ]; then
    echo ">> 저지연 모드로 전환합니다..."
    sudo systemctl enable i-sibal-lowlat.service
    sudo systemctl start i-sibal-lowlat.service
    echo ">> 완료! (i-sibal-lowlat.service 동작 중)"
else
    echo "오류: 알 수 없는 모드입니다. 'stable' 또는 'lowlat' 중 하나를 입력하세요."
    exit 1
fi
