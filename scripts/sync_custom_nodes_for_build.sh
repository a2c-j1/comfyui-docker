#!/bin/sh
# Mirror custom-node source code into this worktree before building an image.
# Docker build contexts cannot safely consume a symlink to the operational
# checkout, while the Dockerfiles install requirements from data/custom_nodes.
set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 SOURCE_CUSTOM_NODES_DIRECTORY" >&2
    exit 64
fi

source_dir=$1
target_dir=data/custom_nodes

if [ ! -d "$source_dir" ]; then
    echo "Source directory does not exist: $source_dir" >&2
    exit 66
fi

source_abs=$(cd "$source_dir" && pwd -P)
target_abs=$(cd "$target_dir" && pwd -P)
if [ "$source_abs" = "$target_abs" ]; then
    echo "Source and target must be different directories." >&2
    exit 64
fi

rsync -a --delete \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='.gitkeep' \
    "$source_abs/" "$target_abs/"

echo "Synchronized custom nodes into $target_dir for this worktree."
