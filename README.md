# ComfyUI Docker

This repo provides a Docker setup for running ComfyUI with optional TLS.

## Requirements

- Docker Engine + Docker Compose (v2)
- NVIDIA GPU + NVIDIA Container Toolkit (for GPU usage)

## Services

- `comfyui`: ComfyUI application container

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

3) Build and start ComfyUI:

```bash
docker compose up --build
```

4) Access:

- https://localhost:8188

## TLS Configuration

ComfyUI reads TLS key/cert paths from environment variables:

- `TLS_KEYFILE` (default in compose: `/app/ComfyUI/certs/key.pem`)
- `TLS_CERTFILE` (default in compose: `/app/ComfyUI/certs/cert.pem`)

If both files exist, HTTPS is enabled. If either file is missing, ComfyUI starts
over HTTP.

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

## Notes

- If you want HTTPS, generate certs into `./certs` before starting.
