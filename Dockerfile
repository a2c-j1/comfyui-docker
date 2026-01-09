FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

# Install ComfyUI
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git \
    && cd /app/ComfyUI \
    && git fetch --depth 1 origin tag v0.8.2 \
    && git checkout v0.8.2
WORKDIR /app/ComfyUI
RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir -r manager_requirements.txt \
    && python -m pip install --no-cache-dir uv GitPython toml

# Create entrypoint script for optional TLS support
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create a non-root user to run the application
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g 1000 appuser && \
    chown -R appuser:appuser /app && \
    chown -R 1000:1000 /opt/conda
USER appuser

EXPOSE 8188

ENTRYPOINT ["/app/entrypoint.sh"]
