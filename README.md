# ComfyUI Docker

This repo provides a Docker setup for running ComfyUI with optional TLS.

## Requirements

- Docker Engine + Docker Compose (v2)
- NVIDIA GPU + NVIDIA Container Toolkit (for GPU usage)

## Services

- `comfyui`: ComfyUI application container

## Enabled Features (This Image)

- ComfyUI `v0.8.2` (pinned release tag)
- ComfyUI Manager enabled (`--enable-manager`)
- CUDA-enabled PyTorch runtime (NVIDIA GPU required for GPU acceleration)
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
- `./data/models`
- `./data/input`
- `./data/output`
- `./certs`

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
- The Dockerfile pins ComfyUI to the `v0.8.2` release tag.
- Verified only on Ubuntu Desktop 24.02 with an RTX 5070.
