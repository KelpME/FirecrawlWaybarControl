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
Description=Firecrawl API Server (Docker)
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=%h/firecrawl
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
Environment=HOME=%h

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable firecrawl.service
systemctl --user start firecrawl.service

echo "Docker compose started."
echo "Run 'omarchy-restart-waybar' to see the icon."