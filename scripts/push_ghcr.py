#!/usr/bin/env python3
import getpass
import os
import subprocess
import sys

OWNER = "a2c-j1"
IMAGE = "comfyui"
DEFAULT_TAGS = ["latest", "v0.9.1"]


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd))
    subprocess.run(cmd, check=True)


def main() -> int:
    token = os.environ.get("GHCR_TOKEN")
    if not token:
        token = getpass.getpass("GHCR PAT (write:packages): ")

    image = f"ghcr.io/{OWNER}/{IMAGE}"
    tags = sys.argv[1:] if len(sys.argv) > 1 else DEFAULT_TAGS

    subprocess.run(
        ["docker", "login", "ghcr.io", "-u", OWNER, "--password-stdin"],
        input=token + "\n",
        text=True,
        check=True,
    )

    build_tag = tags[0]
    run(["docker", "build", "-t", f"{image}:{build_tag}", "."])

    for tag in tags[1:]:
        run(["docker", "tag", f"{image}:{build_tag}", f"{image}:{tag}"])

    for tag in tags:
        run(["docker", "push", f"{image}:{tag}"])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
