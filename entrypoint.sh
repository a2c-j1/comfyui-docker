#!/bin/sh
set -eu

cd /app/ComfyUI

args="python main.py --listen 0.0.0.0 --enable-manager"
if [ -n "${TLS_KEYFILE:-}" ] && [ -n "${TLS_CERTFILE:-}" ] && [ -f "$TLS_KEYFILE" ] && [ -f "$TLS_CERTFILE" ]; then
  args="$args --tls-keyfile $TLS_KEYFILE --tls-certfile $TLS_CERTFILE"
fi

exec $args
