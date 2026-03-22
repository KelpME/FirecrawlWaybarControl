#!/bin/bash

status=$(systemctl --user is-active firecrawl.service 2>/dev/null)

case "$status" in
    active) systemctl --user stop firecrawl.service ;;
    *) systemctl --user start firecrawl.service ;;
esac