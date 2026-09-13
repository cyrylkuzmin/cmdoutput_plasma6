# cmdoutput - KDE Plasma 6 Widget

A simple KDE Plasma 6 widget that displays the output of shell commands directly in your panel or desktop. Perfect for monitoring system metrics, showing weather, custom status indicators, and more.

## Features

- 🚀 **Fast & Lightweight** - Native C++/Qt implementation without legacy dependencies
- 🔄 **Auto-refresh** - Configurable update intervals
- 🖱️ **Click to Refresh** - Manually refresh output on demand
- ⚡ **Zero Dependencies** - No `plasma5support` compatibility layer needed
- 🎨 **Easy Configuration** - Simple settings UI for command and update interval

## Requirements

- KDE Plasma 6.x
- Qt 6.x
- CMake 3.16+
- C++ compiler (GCC/Clang)

### Installing Dependencies

#### Arch Linux
```bash
sudo pacman -S cmake gcc ninja qt6-base
```

#### Ubuntu / Debian
```bash
sudo apt-get install cmake g++ ninja-build qt6-base-dev
```

#### Fedora
```bash
sudo dnf install cmake gcc-c++ ninja-build qt6-qtbase-devel
```

## Installation

This project consists of two components:

1. **CommandRunner** - A C++ QML plugin that wraps command execution via `QProcess`
  - Located in: `cmdoutput_plasma6/contents/code/CommandRunner.{h,cpp}`
  - Compiled and installed to: `/usr/lib/qt6/qml/org/kde/plasma/private/commandrunner/`

2. **Plasmoid (Widget)** - The QML UI and configuration files
   - Located in: `cmdoutput_plasma6/` folder (metadata.json, contents/ui/, contents/config/)
   - Installed to: `~/.local/share/plasma/plasmoids/cmdoutput_plasma6/`

### Quick Install (Recommended)

Simply run the installation script:

```bash
sudo bash install.sh
```

This will:
1. Check for all required dependencies
2. Build the CommandRunner plugin
3. Install the plasmoid widget
4. Configure your environment
5. Provide next steps

### Manual Installation

If you prefer to install manually, follow these steps:

#### Step 1: Build and Install the CommandRunner Plugin

```bash
cd cmdoutput_plasma6/contents/code
bash build-install.sh
```

This will:
1. Compile the C++ plugin
2. Install it to `/usr/lib/qt6/qml/org/kde/plasma/private/commandrunner/`
3. Display setup instructions if needed

#### Step 2: Install the Plasmoid Widget

```bash
mkdir -p ~/.local/share/plasma/plasmoids/
rm -rf ~/.local/share/plasma/plasmoids/cmdoutput_plasma6
cp -r cmdoutput_plasma6 ~/.local/share/plasma/plasmoids/cmdoutput_plasma6
```

#### Step 3: Restart Plasma

```bash
kquitapp6 plasmashell; plasmashell &
```

Or simply:
```bash
plasmashell --replace &
```

### Troubleshooting: Qt Module Not Found

If you see: `module "org.kde.plasma.private.commandrunner" is not installed`

The preferred solution is to install the module into the standard Qt6 QML directory so Plasma can find it after a full restart without depending on shell startup files.

Install with root privileges:

```bash
sudo bash install.sh
```

or directly:

```bash
cd cmdoutput_plasma6/contents/code
sudo PREFIX=/usr bash build-install.sh
```

This installs the plugin under:

```bash
/usr/lib/qt6/qml/org/kde/plasma/private/commandrunner/
```

Then restart Plasma:

```bash
kquitapp6 plasmashell; plasmashell --replace &
```

If the user does not want a system-wide install, then `QML2_IMPORT_PATH` must be set before Plasma starts, not in `~/.zshrc` or `~/.bashrc` for an already-running session. For example, create a Plasma startup script:

```bash
mkdir -p ~/.config/plasma-workspace/env
cat > ~/.config/plasma-workspace/env/99-cmdoutput-qml-import.sh <<'EOF'
#!/usr/bin/env bash
for p in \
  "$HOME/.local/lib/qt6/qml" \
  "$HOME/.local/lib/x86_64-linux-gnu/qt6/qml" \
  "$HOME/.local/qml"
do
  [ -d "$p" ] || continue
  export QML2_IMPORT_PATH="${QML2_IMPORT_PATH:+$QML2_IMPORT_PATH:}$p"
done
EOF
chmod +x ~/.config/plasma-workspace/env/99-cmdoutput-qml-import.sh
```

Then log out/in or restart the Plasma session.

This avoids touching user environment variables in a shell rc file and works reliably after a full Plasma restart.

## Usage

1. Right-click on your Plasma panel and select "Edit Panel"
2. Click the "+" button to add a widget
3. Search for and add "cmdoutput"
4. Configure the command and update interval in the widget settings

### Configuration

- **Command** - Shell command to execute (e.g., `echo 123`, `uptime`, `date`)
- **Max Output Length** - Maximum characters to display (default: 50)
- **Update Interval** - Auto-refresh interval in minutes (0 = disabled)

### Examples

```bash
# Display IP address
hostname -I | awk '{print $1}'

# Show current weather (requires wttr.in or similar)
curl -s "https://wttr.in?format=3" | head -c 50

# Display battery percentage
cat /sys/class/power_supply/BAT0/capacity

# Show number of unread emails
thunderbird-sync | wc -l
```

## Implementation Details

This widget uses a native C++/Qt wrapper around `QProcess` instead of the legacy `PlasmaCore.DataSource` executable engine. This eliminates the need for the `plasma5support` compatibility package.

### Architecture

- **CommandRunner.h/cpp** - C++ QML module that manages command execution
- **main.qml** - QML UI for the compact representation
- **CMakeLists.txt** - Build configuration for Qt6 QML modules

### How It Works

1. User sets a command in the widget settings
2. CommandRunner executes the command via `/bin/sh -c`
3. stdout/stderr are captured and accumulated
4. Output is formatted and displayed in the panel label
5. Auto-refresh timer triggers new executions at configured intervals

## Development

To rebuild the CommandRunner plugin after making changes to C++ code:

```bash
# Clean build
cd cmdoutput_plasma6/contents/code
rm -rf build
bash build-install.sh

# Manual CMake build (alternative)
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/.local ..
cmake --build .
cmake --install .
```

Then restart Plasma to load the changes.

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Contributing

Contributions are welcome! Feel free to:
- Report bugs and request features
- Submit pull requests with improvements
- Share useful command examples

## Author

Created with ❤️ for KDE Plasma enthusiasts

---

**Note:** This is a Plasma 6 widget. For Plasma 5, use a different widget.
