#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$SCRIPT_DIR/build}"
CMAKE_GENERATOR="${CMAKE_GENERATOR:-Ninja}"
PREFIX="${PREFIX:-/usr}"

if ! command -v cmake >/dev/null 2>&1; then
    echo "cmake is required but not installed on PATH." >&2
    exit 1
fi

if ! command -v ninja >/dev/null 2>&1 && ! command -v make >/dev/null 2>&1; then
    echo "Neither ninja nor make is available. Install a build tool first." >&2
    exit 1
fi

mkdir -p "$BUILD_DIR"
cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" \
    -G "$CMAKE_GENERATOR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

cmake --build "$BUILD_DIR"
if ! cmake --install "$BUILD_DIR" --prefix "$PREFIX"; then
    echo "Install failed. Re-run with root access: sudo PREFIX=/usr bash $0" >&2
    exit 1
fi

echo
echo "QML plugin installed under the standard Qt6 path: $PREFIX/lib/qt6/qml/org/kde/plasma/private/commandrunner"
echo "No QML2_IMPORT_PATH change is required."
echo "Restart Plasma to reload the widget:"
echo "  kquitapp6 plasmashell; plasmashell --replace &"
