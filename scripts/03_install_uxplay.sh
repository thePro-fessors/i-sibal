#!/usr/bin/env bash
set -e

echo "=== [3/4] Installing UxPlay (AirPlay Server) ==="

UXPLAY_DIR="$HOME/UxPlay"

UXPLAY_VERSION="v1.69" # Stable pinned version

if [ -d "$UXPLAY_DIR" ]; then
    echo ">> Updating existing UxPlay source to $UXPLAY_VERSION..."
    cd "$UXPLAY_DIR"
    git fetch --all --tags
    git checkout "$UXPLAY_VERSION"
else
    echo ">> Cloning UxPlay repository (Version: $UXPLAY_VERSION)..."
    cd "$HOME"
    git clone --branch "$UXPLAY_VERSION" https://github.com/FDH2/UxPlay.git
    cd UxPlay
fi

echo ">> Preparing build..."
mkdir -p build
cd build
cmake ..

echo ">> Compiling and installing UxPlay (This may take some time)..."
make -j4
sudo make install

echo "=== Done ==="
echo "UxPlay has been installed to /usr/local/bin/uxplay."
