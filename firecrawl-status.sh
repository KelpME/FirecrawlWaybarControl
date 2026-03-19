#!/bin/bash
status=$(systemctl --user is-active firecrawl.service 2>/dev/null)

case "$status" in
    active) echo "●" ;;
    *) echo "◌" ;;
esac
