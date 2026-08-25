#!/bin/sh
set -eu

node_dir=/app/ComfyUI/custom_nodes/ComfyUI-Hunyuan3DWrapper
if [ ! -e "$node_dir" ]; then
    ln -s /opt/ComfyUI-Hunyuan3DWrapper "$node_dir"
fi

exec /app/entrypoint.sh "$@"
