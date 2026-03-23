#!/bin/bash

cd "$HOME/firecrawl"

CONTAINER_NAME="firecrawl-api-1"
STATUS=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)

case "$STATUS" in
    true) docker compose down ;;
    *) docker compose up -d ;;
esac