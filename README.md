# ComfyUI Docker

This repo provides a Docker setup for running ComfyUI with optional TLS.

## Requirements

- Docker Engine + Docker Compose (v2)
- NVIDIA GPU + NVIDIA Container Toolkit (for GPU usage)

## Services

- `comfyui`: ComfyUI application container
- `omgwtfssl`: one-off helper to create self-signed certs (writes to `./certs`)

## Quick Start

1) Generate certificates (first run, optional for HTTPS):

```bash
docker compose run --rm omgwtfssl
```

2) Build and start ComfyUI:

```bash
docker compose up --build
```

3) Access:

- https://localhost:8188

## TLS Configuration

ComfyUI reads TLS key/cert paths from environment variables:

- `TLS_KEYFILE` (default in compose: `/app/ComfyUI/certs/servhostname.local.key`)
- `TLS_CERTFILE` (default in compose: `/app/ComfyUI/certs/servhostname.local.crt`)

If both files exist, HTTPS is enabled. If either file is missing, ComfyUI starts
over HTTP.

## Data Volumes

Host directories are mounted into the container:

- `./data/custom_nodes`
- `./data/user`
- `./data/models`
- `./data/input`
- `./data/output`
- `./certs`

## Notes

- If you want HTTPS, generate certs into `./certs` before starting by running
  `docker compose run --rm omgwtfssl`.
