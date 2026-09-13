#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# cmdoutput Plasma6 installer
#
# This script builds and installs the CommandRunner QML plugin and the
# plasmoid widget. It is intended to be run from the repository root like:
#
#   bash install.sh
#
# Key behaviour notes for maintainers and users:
# - The Qt plugin is installed into the system Qt6 QML import path by
#   default (PREFIX=/usr). The script refuses to install the plugin into
#   locations under $HOME to avoid confusing runtime QML layouts.
# - When run as root (sudo), the plasmoid files are installed to
#   /usr/share/plasma/plasmoids/...; when run as a normal user the
#   plasmoid is copied into the user's local plasmoids directory.
# - The script checks for basic build tools and Qt6 dev files and exits
#   early with helpful hints if they are missing.
# - Use `PREFIX=/usr bash install.sh` when you want system-wide install.
#
# Maintainability: keep the messages here in sync with README.md and with
# the CMake install target in `contents/code/CMakeLists.txt`.
# ---------------------------------------------------------------------------

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_error() {
    # Print an error message in red to stderr. Keep messages short and
    # actionable so users know how to proceed.
    echo -e "${RED}✗ Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    # Informational messages (yellow). Used for progress and helpful hints.
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_command() {
    # Simple helper to check for required executables on PATH. Returns 0
    # when the command exists and prints a success message; returns 1 and
    # prints an error message otherwise.
    if command -v "$1" &> /dev/null; then
        print_success "Found: $1"
        return 0
    else
        print_error "Missing: $1"
        return 1
    fi
}

# Header: concise visible separator for interactive runs
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

# If any required tools are missing, show distro-specific hints and exit.
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
    # Exit early to avoid confusing partial builds.
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Defaults and directory layout
# - PREFIX controls where CMake will install the Qt plugin. System
#   installations should use /usr (the default). User installs are
#   intentionally rejected for the Qt plugin to avoid runtime import
#   confusion.
PREFIX="${PREFIX:-/usr}"
BUILD_DIR="${SCRIPT_DIR}/cmdoutput_plasma6/contents/code/build"
CODE_DIR="${SCRIPT_DIR}/cmdoutput_plasma6/contents/code"
PLASMOID_DIR="${SCRIPT_DIR}/cmdoutput_plasma6"

# Safety check: do not allow the Qt plugin install prefix to resolve under
# the current user's home directory. Installing Qt modules under $HOME can
# produce unexpected QML import layouts and is intentionally forbidden.
if [[ "$PREFIX" == "$HOME"* ]]; then
    print_error "Refusing to install Qt plugin under home directory. Use a system prefix (e.g. /usr) and run with sudo: sudo PREFIX=/usr bash $0"
    exit 1
fi

# Install plasmoid to system location when running as root, otherwise to the user's local plasmoids dir.
# Decide where to place the plasmoid files:
# - system-wide (when running as root): /usr/share/plasma/plasmoids/
# - per-user (normal user runs): $HOME/.local/share/plasma/plasmoids/
if [ "$(id -u)" -eq 0 ]; then
    PLASMOID_INSTALL_DIR="/usr/share/plasma/plasmoids/cmdoutput_plasma6"
else
    PLASMOID_INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/cmdoutput_plasma6"
fi

print_info "Installation prefix: $PREFIX"
print_info "Qt6 module install target: $PREFIX/lib/qt6/qml/org/kde/plasma/private/commandrunner"
print_info "Build directory: $BUILD_DIR"
echo ""

# Step 1: Build and install CommandRunner plugin
print_info "Step 1: Building and installing CommandRunner plugin..."
echo ""

# Prepare a clean build directory to avoid stale CMake cache issues.
if [ -d "$BUILD_DIR" ]; then
    print_info "Cleaning old build directory..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

# Run the out-of-source CMake configure step. We explicitly pass the
# install prefix so `cmake --install` later writes files under PREFIX.
cd "$CODE_DIR"

print_info "Running CMake..."
cmake -S . -B "$BUILD_DIR" \
    -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

print_info "Building..."
cmake --build "$BUILD_DIR"

print_info "Installing plugin..."
# Use `cmake --install` which honors the prefix given above. If this
# fails, suggest the common remedy (run with sudo and PREFIX=/usr).
if ! cmake --install "$BUILD_DIR" --prefix "$PREFIX"; then
    print_error "Installation failed. Try: sudo PREFIX=/usr bash $0"
    exit 1
fi

print_success "CommandRunner plugin installed"
echo ""

# Step 2: Install plasmoid widget
print_info "Step 2: Installing plasmoid widget..."
echo ""

# Ensure the target plasmoids directory exists. If installing system-wide
# this will create directories under /usr/share; if per-user, $HOME is used.
mkdir -p "$(dirname "$PLASMOID_INSTALL_DIR")"

if [ -d "$PLASMOID_INSTALL_DIR" ]; then
    print_info "Removing old plasmoid installation..."
    rm -rf "$PLASMOID_INSTALL_DIR"
fi

print_info "Copying plasmoid files..."
# Copy the entire plasmoid directory tree. This is a simple approach that
# avoids packaging; packaging would be preferable for distro deployment.
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
