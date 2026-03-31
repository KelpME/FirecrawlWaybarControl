#!/bin/bash

CONTAINER_NAME="firecrawl-api-1"
STATUS=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)

ENV_FILE="$HOME/firecrawl/apps/api/.env"
if [[ -f "$ENV_FILE" ]]; then
    PORT=$(grep "^PORT=" "$ENV_FILE" | cut -d'=' -f2)
fi
[[ -z "$PORT" ]] && PORT=3002

if [ "$STATUS" = "true" ]; then
    echo "{\"text\": \"🔥\", \"tooltip\": \"Firecrawl\nhttp://localhost:${PORT}\"}"
else
    echo "{\"text\": \"💤\", \"tooltip\": \"Firecrawl (Stopped)\nhttp://localhost:${PORT}\"}"
fi
