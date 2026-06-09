# syntax=docker/dockerfile:1.4
FROM pytorch/pytorch:2.9.1-cuda13.0-cudnn9-runtime

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libgl1 \
    libglib2.0-0

RUN groupadd -g 1000 appuser \
    && useradd -m -u 1000 -g 1000 appuser \
    && mkdir -p /app \
    && chown appuser:appuser /app

# Install ComfyUI
WORKDIR /app
USER appuser
RUN git clone --depth 1 --branch v0.24.0 https://github.com/comfyanonymous/ComfyUI.git
USER root
WORKDIR /app/ComfyUI
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install -r requirements.txt \
    && python -m pip install -r manager_requirements.txt \
    && python -m pip install uv GitPython toml \
    && python -m pip install matrix-nio

RUN --mount=type=bind,source=data/custom_nodes,target=/tmp/custom_nodes,readonly \
    --mount=type=cache,target=/root/.cache/pip \
    export CC=/usr/bin/gcc \
    && export CXX=/usr/bin/g++ \
    && find /tmp/custom_nodes -mindepth 2 -maxdepth 2 \
        \( -iname 'requirements*.txt' -o -iname 'requirement*.txt' \) \
        -not -path '*/.disabled/*' -print0 \
    | sort -z \
    | xargs -0 -r -n 1 python -m pip install -r


# Create entrypoint script for optional TLS support
WORKDIR /app
COPY --chown=appuser:appuser --chmod=755 entrypoint.sh /app/entrypoint.sh
ENV PIP_USER=1 \
    PYTHONUSERBASE=/home/appuser/.local \
    PATH=/home/appuser/.local/bin:$PATH
USER appuser

EXPOSE 8188

ENTRYPOINT ["/app/entrypoint.sh"]
