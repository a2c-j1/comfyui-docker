FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

# Install ComfyUI
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir  -r requirements.txt

# Install ComfyUI-Manager
WORKDIR /app/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Create entrypoint script for optional TLS support
WORKDIR /app
RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -eu' \
    '' \
    'cd /app/ComfyUI' \
    'if [ ! -d /app/ComfyUI/custom_nodes/ComfyUI-Manager ]; then' \
    '  git clone https://github.com/ltdrdata/ComfyUI-Manager.git /app/ComfyUI/custom_nodes/ComfyUI-Manager' \
    'fi' \
    'args="python main.py --listen 0.0.0.0"' \
    'if [ -n "${TLS_KEYFILE:-}" ] && [ -n "${TLS_CERTFILE:-}" ] && [ -f "$TLS_KEYFILE" ] && [ -f "$TLS_CERTFILE" ]; then' \
    '  args="$args --tls-keyfile $TLS_KEYFILE --tls-certfile $TLS_CERTFILE"' \
    'fi' \
    '' \
    'exec $args' \
    > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Create a non-root user to run the application
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8188

ENTRYPOINT ["/app/entrypoint.sh"]
