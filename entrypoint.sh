#!/bin/sh
set -eu

cd /app/ComfyUI
if [ ! -d /app/ComfyUI/custom_nodes/ComfyUI-Manager ]; then
  git clone https://github.com/ltdrdata/ComfyUI-Manager.git /app/ComfyUI/custom_nodes/ComfyUI-Manager
  if [ -f /app/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt ]; then
    python -m pip install --no-cache-dir -r /app/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt
  fi
fi

args="python main.py --listen 0.0.0.0"
if [ -n "${TLS_KEYFILE:-}" ] && [ -n "${TLS_CERTFILE:-}" ] && [ -f "$TLS_KEYFILE" ] && [ -f "$TLS_CERTFILE" ]; then
  args="$args --tls-keyfile $TLS_KEYFILE --tls-certfile $TLS_CERTFILE"
fi

exec $args
