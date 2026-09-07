# ComfyUI Docker

This repo provides a Docker setup for running ComfyUI with optional TLS.

## Requirements

- Docker Engine + Docker Compose (v2)
- NVIDIA GPU + NVIDIA Container Toolkit (for GPU usage)

## Services

- `comfyui`: ComfyUI application container

## Enabled Features (This Image)

- ComfyUI `v0.33.4` (pinned release tag)
- ComfyUI Manager enabled (`--enable-manager`)
- CUDA-enabled PyTorch runtime (PyTorch 2.9.1 + CUDA 13.0; NVIDIA GPU required for GPU acceleration)
- SoundFile installed for audio-saving custom nodes
- Optional HTTPS/TLS if `TLS_KEYFILE` and `TLS_CERTFILE` are provided
- Data persistence via mounted volumes (`./data/*`, `./certs`)

## Quick Start

1) Generate certificates (first run, optional for HTTPS):

```bash
cp certs/san.conf.example certs/san.conf
```

Edit `certs/san.conf` to match your server environment (for example, update
`DNS.1` / `IP.1` to your actual hostname and IP).

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
  -keyout certs/key.pem -out certs/cert.pem \
  -config certs/san.conf -extensions req_ext
```

2) Create the compose file:

```bash
cp compose.yml.example compose.yml
```

3) (Optional) Adjust `compose.yml` for your environment:

- Change `ports` if 8188 is already in use
- Comment out TLS env vars to force HTTP
- Set `CUDA_VISIBLE_DEVICES` to limit GPU use

4) Build and start ComfyUI:

```bash
docker compose up --build
```

5) Access:

- https://localhost:8188

## Container Registry (GHCR)

Public images are published to GHCR.

- Image: `ghcr.io/a2c-j1/comfyui`
- Tags: `latest`, `v0.33.4`

Example:

```bash
docker pull ghcr.io/a2c-j1/comfyui:latest
```

## TLS Configuration

ComfyUI reads TLS key/cert paths from environment variables:

- `TLS_KEYFILE` (default in compose: `/app/ComfyUI/certs/key.pem`)
- `TLS_CERTFILE` (default in compose: `/app/ComfyUI/certs/cert.pem`)

If both files exist, HTTPS is enabled. If either file is missing, ComfyUI starts
over HTTP.

## Environment Variables

Required:

- None

Optional:

- `TLS_KEYFILE` / `TLS_CERTFILE` (enable HTTPS when both files exist)
- `CUDA_VISIBLE_DEVICES` (limit visible GPUs)

## Client Trust (Self-Signed Certificates)

If you use a self-signed certificate, you need to trust `./certs/cert.pem` on
the client device.

### Windows (Chrome)

1) Double-click `./certs/cert.pem`  
2) "Install Certificate" → "Local Machine"  
3) "Place all certificates in the following store" → "Trusted Root Certification Authorities"  
4) Restart Chrome

### Ubuntu (Chrome)

Add to OS trust store:

```bash
sudo cp ./certs/cert.pem /usr/local/share/ca-certificates/cert.pem
sudo update-ca-certificates
```

If Chrome still shows a warning, add to NSS:

```bash
sudo apt-get install -y libnss3-tools
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "comfyui-local" -i ./certs/cert.pem
```

### iPad (Safari)

1) Send `cert.pem` to the iPad (AirDrop, etc.)  
2) Settings → General → VPN & Device Management → Install Profile  
3) Settings → General → About → Certificate Trust Settings → enable "Full Trust"  
4) Restart Safari

## Data Volumes

Host directories are mounted into the container:

- `./data/custom_nodes`
- `./data/user`
- `./data/__manager`
- `./data/models`
- `./data/input`
- `./data/output`
- `./certs`

If an existing installation has ComfyUI Manager config, snapshots, or cache under `./data/user/__manager`, move the files you need to `./data/__manager`.

## Model & Data Placement Examples

Place files under `./data/models` to match ComfyUI's expected structure, for example:

- `./data/models/checkpoints/your_model.safetensors`
- `./data/models/vae/your_vae.safetensors`
- `./data/models/loras/your_lora.safetensors`
- `./data/models/clip/your_clip.safetensors`
- `./data/models/controlnet/your_controlnet.safetensors`
- `./data/models/upscale_models/your_upscaler.pth`

Inputs go in `./data/input`, and outputs are saved to `./data/output`.

## Notes

- If you want HTTPS, generate certs into `./certs` before starting.
- The Dockerfile pins ComfyUI to the `v0.33.4` release tag.
- The base image uses PyTorch 2.9.1 with CUDA 13.0 (cudnn9 runtime).
- Verified only on Ubuntu Desktop 24.04 with an RTX 5070.
- WSL2 has not been tested.

## Hunyuan3D Paint (texturing existing meshes)

For adding textures to an existing GLB or OBJ, run a dedicated service instead
of replacing the regular `comfyui` service:

```bash
docker build -f Dockerfile.hunyuan3d-paint -t comfyui-docker:hunyuan3d-paint .
docker compose -f compose.hunyuan3d-paint.example.yml up -d
```

- The UI is available at `https://localhost:8189` by default.
- Existing custom-node sources are shared read-only with the normal service.
  The Paint wrapper is added only inside the dedicated container and is never
  written into the normal service's `data/custom_nodes` directory.
- Models, inputs, and outputs are shared with `comfyui`; the Paint service
  keeps its `data/user` and `data/__manager` in its own worktree to avoid
  contention for ComfyUI's SQLite database.
- Place the texture model in `data/models/diffusers/hunyuan3d-paint-v2-0` or
  `hunyuan3d-paint-v2-0-turbo`.
- On an RTX 5070 (12 GB), start with the Turbo model and a small texture size.

The derived image builds a Linux `custom_rasterizer`; its first build downloads
a CUDA development image and compiles the extension.

## Migrating to one ComfyUI service with Paint

Instead of running normal and Paint services separately, you can run one
`comfyui` service that keeps the existing persistent data. The Paint wrapper is
added only inside the container, so `data/custom_nodes` is unchanged.

Stop the current ComfyUI before switching; two services must not open the same
`data/user/comfyui.db` at the same time.

```bash
./scripts/sync_custom_nodes_for_build.sh /home/a2c/deploy/comfyui-docker/data/custom_nodes
export COMFYUI_DATA_DIR=/home/a2c/deploy/comfyui-docker/data
docker compose -f compose.unified-paint.example.yml up --build -d
```

This compose uses port 8188 and keeps the existing user data, Manager settings,
models, inputs, and outputs. Open `http://localhost:8188` after it starts. Stop
and remove the former Paint service on port 8189 only after confirming it works.

## Using existing data from a dev worktree

When building from a `dev` worktree without changing the operational `main` checkout, first
sync the custom-node sources into the worktree. Docker build contexts do not use a symlink to
the operational checkout.

```bash
./scripts/sync_custom_nodes_for_build.sh /home/a2c/deploy/comfyui-docker/data/custom_nodes
docker build -t comfyui-docker:dev-main-paint .
docker build -f Dockerfile.hunyuan3d-paint -t comfyui-docker:dev-main-paint-hunyuan3d .
```

At runtime, set `COMFYUI_DATA_DIR` to an absolute existing `data` directory to share models,
inputs, outputs, and custom nodes. The Paint service keeps user and Manager settings in its
own worktree to avoid SQLite contention.

```bash
export COMFYUI_DATA_DIR=/home/a2c/deploy/comfyui-docker/data
docker compose -f compose.hunyuan3d-paint.example.yml up -d
```

To run the normal image on a separate port, copy `compose.yml.example` and change its port and
`container_name`; this does not stop or overwrite the operational `comfyui` container.

## Upstream License (ComfyUI)

This repository packages and runs the upstream ComfyUI project. ComfyUI is
licensed under GPL-3.0. Your use, modification, and distribution of ComfyUI
are governed by its license. Please review the upstream license terms before
redistribution.

## Disclaimer

This repository is provided "as is", without warranty of any kind. Use at your
own risk. The maintainers are not responsible for any damages or losses
resulting from use of this repository or the upstream software it runs.
