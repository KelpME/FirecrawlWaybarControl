#!/bin/bash

CONTAINER_NAME="firecrawl-api-1"
STATUS=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)

ENV_FILE="$HOME/firecrawl/apps/api/.env"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
CACHE_FILE="/tmp/firecrawl-port-cache"

if [[ -f "$ENV_FILE" ]]; then
    PORT=$(grep "^PORT=" "$ENV_FILE" | cut -d'=' -f2)
fi

if [[ -z "$PORT" ]]; then
    PORT=3002
fi

CACHED_PORT=""
if [[ -f "$CACHE_FILE" ]]; then
    CACHED_PORT=$(cat "$CACHE_FILE")
fi

if [[ "$PORT" != "$CACHED_PORT" ]] && [[ -f "$WAYBAR_CONFIG" ]]; then
    sed -i "s|http://192\.168\.1\.8:[0-9]*|http://192.168.1.8:${PORT}|g" "$WAYBAR_CONFIG"
    sed -i "s|http://localhost:[0-9]*|http://localhost:${PORT}|g" "$WAYBAR_CONFIG"
    echo "$PORT" > "$CACHE_FILE"
fi

case "$STATUS" in
    true) echo "●" ;;
    *) echo "◌" ;;
esac