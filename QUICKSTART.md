# Quick Start Guide

## Installation

```bash
git clone https://github.com/cyrylkuzmin/cmdoutput_plasma6.git
cd cmdoutput_plasma6
bash install.sh
plasmashell --replace &
```

## Add to Panel

1. Right-click Plasma panel → Edit Panel
2. Click + to add widget
3. Search "Command Output"
4. Configure settings

## Useful Commands

### System Information
```bash
# CPU Usage
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

# Memory Usage
free -h | awk '/^Mem/ {print $3 "/" $2}'

# Disk Usage
df -h / | tail -1 | awk '{print $5}'

# Uptime
uptime | awk -F, '{print $1}' | awk '{print $(NF-2), $(NF-1), $NF}'

# System Load
cat /proc/loadavg | awk '{print $1, $2, $3}'

# Something more complex
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}'); temp=$(sensors | awk '/Tctl:|Core 0|CPU Temperature|Package id 0/ {print $2; exit}' | tr -d '+°C' | cut -d'.' -f1); ram=$(free | awk '/Mem:/ {printf "%.1f%%", $3/$2 * 100}'); gpu=$(nvtop -s | jq -r '.[] | "GPU: " + .gpu_clock + " | " + .temp + " | " + .power_draw'); echo "CPU: $cpu | ${temp:-N/A}C | RAM: $ram | $gpu"
```

### Network
```bash
# Public IP
curl -s https://icanhazip.com

# Local IP
hostname -I | awk '{print $1}'

# Ping (check connectivity)
ping -c 1 8.8.8.8 > /dev/null && echo "Online" || echo "Offline"
```

### Time & Date
```bash
# Current Time
date +"%H:%M"

# Date
date +"%Y-%m-%d"

# Week Number
date +"%V"
```

### Battery & Power
```bash
# Battery Percentage
cat /sys/class/power_supply/BAT0/capacity

# Battery Status
cat /sys/class/power_supply/BAT0/status

# Temperature
sensors | grep "Core 0" | awk '{print $3}'
```

### Custom Scripts
Create a script and call it:
```bash
~/.local/bin/my-widget-script.sh
```

## Troubleshooting

**Widget shows "No command set"**
- Go to widget settings and enter a command

**Widget shows "Command failed"**
- Check command syntax in terminal
- Ensure all paths are absolute (e.g., `/usr/bin/uptime`)

**"No output" display**
- Verify command produces output
- Check for stderr messages in Plasma logs

**Module not found error**
- Run: `export QML2_IMPORT_PATH="$HOME/.local/lib/qt6/qml:${QML2_IMPORT_PATH:-}"`
- Add to `~/.bashrc` or `~/.zshrc` for permanent fix

## Performance Tips

- Avoid expensive commands in auto-refresh
- Use short `Max Output Length` (30-50 chars)
- Set reasonable update intervals (1+ minutes)
- Prefer fast utilities over heavy scripts

## Support

Issues? Check the [GitHub repository](https://github.com/cyrylkuzmin/cmdoutput_plasma6/issues)
