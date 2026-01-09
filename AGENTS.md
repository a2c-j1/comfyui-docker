# AGENTS

## Project overview
- Docker image + Compose setup to run ComfyUI with optional TLS support.
- Image pins ComfyUI to a release tag in `Dockerfile` and uses `entrypoint.sh` to enable HTTPS when certs are present.

## Key files
- `Dockerfile`: Builds the runtime image and pins the ComfyUI version.
- `entrypoint.sh`: Starts ComfyUI and toggles TLS based on env vars + cert presence.
- `compose.yml` / `compose.yml.example`: Local deployment configuration.
- `certs/`: TLS certificate assets (self-signed workflow in README).
- `test/container-structure-test.yaml`: Container structure test configuration.
- `.github/workflows/container-structure-test.yml`: CI workflow for image build + structure tests.

## Local workflows
- Build and run:
  - `docker compose up --build`
- Build image only:
  - `docker build -t comfyui-docker:local .`

## Tests
- Container structure tests (same as CI):
  - `docker build -t comfyui-docker:test .`
  - `docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(pwd):/workdir" \
      -w /workdir \
      gcr.io/gcp-runtimes/container-structure-test:latest \
      test --image comfyui-docker:test --config test/container-structure-test.yaml`

## Notes
- TLS is enabled only if both `TLS_KEYFILE` and `TLS_CERTFILE` exist inside the container.
- Data persistence is via `./data/*` and `./certs` volume mounts.
