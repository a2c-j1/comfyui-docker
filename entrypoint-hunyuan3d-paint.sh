#!/bin/sh
set -eu

node_root=/app/ComfyUI/custom_nodes

# The regular service and this service share the host's custom-node sources,
# but the Paint wrapper must stay private to this image.  Recreate enabled host
# nodes as container-local links so no link into /opt is written back to data/.
for source_node in /mnt/host-custom-nodes/*; do
    [ -e "$source_node" ] || continue
    node_name=$(basename "$source_node")
    if [ ! -e "$node_root/$node_name" ]; then
        ln -s "$source_node" "$node_root/$node_name"
    fi
done

paint_node=$node_root/ComfyUI-Hunyuan3DWrapper
if [ ! -e "$paint_node" ]; then
    ln -s /opt/ComfyUI-Hunyuan3DWrapper "$paint_node"
fi

exec /app/entrypoint.sh "$@"
