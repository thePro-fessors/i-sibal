#!/usr/bin/env bash
set -e

echo "=== [3/4] UxPlay (AirPlay 서버) 설치 ==="

UXPLAY_DIR="$HOME/UxPlay"

if [ -d "$UXPLAY_DIR" ]; then
    echo ">> 기존 UxPlay 소스를 업데이트합니다..."
    cd "$UXPLAY_DIR"
    git pull
else
    echo ">> UxPlay 소스 저장소를 다운로드합니다..."
    cd "$HOME"
    git clone https://github.com/FDH2/UxPlay.git
    cd UxPlay
fi

echo ">> 빌드를 준비합니다..."
mkdir -p build
cd build
cmake ..

echo ">> UxPlay 컴파일 및 설치 중 (시간이 소요될 수 있습니다)..."
make -j4
sudo make install

echo "=== 완료 ==="
echo "UxPlay가 /usr/local/bin/uxplay 에 설치되었습니다."
