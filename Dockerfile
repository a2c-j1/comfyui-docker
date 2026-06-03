# syntax=docker/dockerfile:1.4
FROM pytorch/pytorch:2.9.1-cuda13.0-cudnn9-runtime

# Install ComfyUI
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git \
    && cd /app/ComfyUI \
    && git fetch --depth 1 origin tag v0.23.0\
    && git checkout v0.23.0
WORKDIR /app/ComfyUI
RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir -r manager_requirements.txt \
    && python -m pip install --no-cache-dir uv GitPython toml \
    && python -m pip install --no-cache-dir  matrix-nio

    
RUN apt update && apt install -y libgl1 libglib2.0-0

RUN apt install -y build-essential \
    && export CC=/usr/bin/gcc \
    && export CXX=/usr/bin/g++

RUN --mount=type=bind,source=data/custom_nodes,target=/tmp/custom_nodes,readonly \
    find /tmp/custom_nodes -mindepth 2 -maxdepth 2 \
        \( -iname 'requirements*.txt' -o -iname 'requirement*.txt' \) \
        -not -path '*/.disabled/*' -print0 \
    | sort -z \
    | xargs -0 -r -n 1 python -m pip install --no-cache-dir -r


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
