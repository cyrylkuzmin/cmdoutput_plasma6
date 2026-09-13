#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "Found: $1"
        return 0
    else
        print_error "Missing: $1"
        return 1
    fi
}

# Header
echo ""
echo "================================"
echo "  cmdoutput Plasma6 Installer"
echo "================================"
echo ""

# Check for required programs
print_info "Checking requirements..."
echo ""

MISSING=false

if ! check_command "cmake"; then
    MISSING=true
fi

if ! check_command "c++"; then
    if ! check_command "g++"; then
        if ! check_command "clang++"; then
            print_error "No C++ compiler found (g++, c++, or clang++ required)"
            MISSING=true
        fi
    fi
fi

if ! check_command "ninja"; then
    if ! check_command "make"; then
        print_error "No build tool found (ninja or make required)"
        MISSING=true
    fi
fi

# Check for Qt6 development files
if ! pkg-config --exists Qt6Core 2>/dev/null && ! pkg-config --exists Qt6Qml 2>/dev/null; then
    print_error "Qt6 development files not found (libqt6core6-dev or similar)"
    MISSING=true
else
    print_success "Found: Qt6 development files"
fi

echo ""

if [ "$MISSING" = true ]; then
    echo -e "${RED}Missing dependencies. Please install them first.${NC}"
    echo ""
    echo "For Arch Linux:"
    echo "  sudo pacman -S cmake gcc ninja qt6-base"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "  sudo apt-get install cmake g++ ninja-build qt6-base-dev"
    echo ""
    echo "For Fedora:"
    echo "  sudo dnf install cmake gcc-c++ ninja-build qt6-qtbase-devel"
    echo ""
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Install into the standard Qt6 import path, not into a user shell environment.
PREFIX="${PREFIX:-/usr}"
BUILD_DIR="${SCRIPT_DIR}/cmdoutput_plasma6/contents/code/build"
CODE_DIR="${SCRIPT_DIR}/cmdoutput_plasma6/contents/code"
PLASMOID_DIR="${SCRIPT_DIR}/cmdoutput_plasma6"
PLASMOID_INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/cmdoutput_plasma6"

print_info "Installation prefix: $PREFIX"
print_info "Qt6 module install target: $PREFIX/lib/qt6/qml/org/kde/plasma/private/commandrunner"
print_info "Build directory: $BUILD_DIR"
echo ""

# Step 1: Build and install CommandRunner plugin
print_info "Step 1: Building and installing CommandRunner plugin..."
echo ""

if [ -d "$BUILD_DIR" ]; then
    print_info "Cleaning old build directory..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

cd "$CODE_DIR"

print_info "Running CMake..."
cmake -S . -B "$BUILD_DIR" \
    -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

print_info "Building..."
cmake --build "$BUILD_DIR"

print_info "Installing plugin..."
if ! cmake --install "$BUILD_DIR" --prefix "$PREFIX"; then
    print_error "Installation failed. Try: sudo PREFIX=/usr bash $0"
    exit 1
fi

print_success "CommandRunner plugin installed"
echo ""

# Step 2: Install plasmoid widget
print_info "Step 2: Installing plasmoid widget..."
echo ""

mkdir -p "$HOME/.local/share/plasma/plasmoids/"

if [ -d "$PLASMOID_INSTALL_DIR" ]; then
    print_info "Removing old plasmoid installation..."
    rm -rf "$PLASMOID_INSTALL_DIR"
fi

print_info "Copying plasmoid files..."
cp -r "$PLASMOID_DIR" "$PLASMOID_INSTALL_DIR"

print_success "Plasmoid widget installed to $PLASMOID_INSTALL_DIR"
echo ""

# Summary
echo "================================"
echo -e "${GREEN}Installation Complete!${NC}"
echo "================================"
echo ""
print_info "Next steps:"
echo "  1. Restart Plasma so the plasmoid and Qt plugin are reloaded:"
echo "     kquitapp6 plasmashell; plasmashell --replace &"
echo ""
echo "  2. Add the widget to your panel:"
echo "     Right-click panel → Edit Panel → + → Search 'cmdoutput'"
echo ""
print_info "The plugin is installed under the standard Qt6 path, so no QML2_IMPORT_PATH changes are needed."
