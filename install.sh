#!/bin/bash
set -e

echo "Installing Firecrawl waybar integration..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRECRCRAWL_DIR="$HOME/firecrawl"

if [ ! -d "$FIRECRCRAWL_DIR" ]; then
    echo "Error: Firecrawl not found at $FIRECRCRAWL_DIR"
    exit 1
fi

mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.local/bin"

cp "$SCRIPT_DIR/firecrawl-status.sh" "$HOME/.local/bin/waybar-firecrawl-status"
cp "$SCRIPT_DIR/firecrawl-toggle.sh" "$HOME/.local/bin/waybar-firecrawl-toggle"
chmod +x "$HOME/.local/bin/waybar-firecrawl-status"
chmod +x "$HOME/.local/bin/waybar-firecrawl-toggle"

cat > "$HOME/.config/systemd/user/firecrawl.service" << 'EOF'
[Unit]
Description=Firecrawl API Server
After=network.target

[Service]
Type=simple
WorkingDirectory=%h/firecrawl/apps/api
ExecStart=/bin/bash -c 'source %h/firecrawl/apps/api/.env 2>/dev/null; %h/firecrawl/apps/api/node_modules/.bin/tsc && node dist/src/index.js'
ExecStartPost=/bin/bash -c '%h/.local/bin/waybar-firecrawl-status'
Restart=on-failure
RestartSec=5
Environment=HOME=%h

[Install]
WantedBy=default.target
EOF

cp "$HOME/.config/systemd/user/firecrawl.service" "$HOME/.config/systemd/user/firecrawl.service.bak.$(date +%s)" 2>/dev/null || true

if grep -q "custom/firecrawl" "$HOME/.config/waybar/config.jsonc" 2>/dev/null; then
    echo "Waybar config already has firecrawl module"
else
    sed -i '/"modules": \[/,/\]/ { /"tray"/a\      "custom/firecrawl", }' "$HOME/.config/waybar/config.jsonc"
    
    PORT=$(grep "^PORT=" "$FIRECRCRAWL_DIR/apps/api/.env" 2>/dev/null | cut -d'=' -f2)
    PORT=${PORT:-3002}
    
    cat >> "$HOME/.config/waybar/config.jsonc" << EOF
,
  "custom/firecrawl": {
    "exec": "~/.local/bin/waybar-firecrawl-status",
    "return-type": "str",
    "format": "{}",
    "tooltip-format": "Firecrawl\nhttp://192.168.1.8:${PORT}\n\nClick to toggle",
    "interval": 30,
    "on-click": "~/.local/bin/waybar-firecrawl-toggle"
  }
EOF
fi

if ! grep -q "#custom-firecrawl," "$HOME/.config/waybar/style.css" 2>/dev/null; then
    sed -i 's/#cpu,/#cpu,\n#custom-firecrawl,/g' "$HOME/.config/waybar/style.css"
fi

systemctl --user daemon-reload
systemctl --user enable firecrawl.service
systemctl --user start firecrawl.service

echo "Done! Firecrawl waybar integration installed."
echo "Run 'omarchy-restart-waybar' to see the icon."