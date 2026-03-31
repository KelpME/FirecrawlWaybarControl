#!/bin/bash

cd "$HOME/firecrawl"

CONTAINER_NAME="firecrawl-api-1"
STATUS=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)

ENV_FILE="$HOME/firecrawl/apps/api/.env"
if [[ -f "$ENV_FILE" ]]; then
    PORT=$(grep "^PORT=" "$ENV_FILE" | cut -d'=' -f2)
fi
[[ -z "$PORT" ]] && PORT=3002

case "$STATUS" in
    true) 
        if curl -sf "http://localhost:$PORT" >/dev/null 2>&1; then
            docker compose down
        else
            notify-send "Firecrawl" "Server not responding on port $PORT"
        fi
        ;;
    *) 
        docker compose up -d
        ;;
esac