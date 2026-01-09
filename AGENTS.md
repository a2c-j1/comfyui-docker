# AGENTS

## 概要
- ComfyUI を Docker + Compose で動かす構成。TLS は任意で有効化可能。
- `Dockerfile` で ComfyUI のリリースタグと PyTorch CUDA ベースイメージを固定し、`entrypoint.sh` で証明書があれば HTTPS を有効化。
- データ永続化はホスト側ディレクトリをボリュームマウントして行う。

## 主要ファイル
- `Dockerfile`: ランタイムイメージをビルドし、ComfyUI バージョンを固定。
- `entrypoint.sh`: ComfyUI を起動し、環境変数と証明書の有無で TLS を切り替え。
- `compose.yml` / `compose.yml.example`: ローカルデプロイ用の設定。
- `certs/`: TLS 証明書（自己署名の手順は README 参照）。
- `test/container-structure-test.yaml`: コンテナ構造テストの設定。
- `.github/workflows/container-structure-test.yml`: イメージビルド + 構造テストの CI。
- `scripts/push_ghcr.py`: GHCR へイメージを公開するための補助スクリプト。

## ローカル作業フロー
- ビルド & 起動:
  - `docker compose up --build`
- イメージのみビルド:
  - `docker build -t comfyui-docker:local .`

## 重要な設定値
- 既定ポート: `8188`
- TLS 有効化条件: `TLS_KEYFILE` と `TLS_CERTFILE` の両方がコンテナ内に存在すること
- 主要ボリューム:
  - `./data/*` (ComfyUI のデータ)
  - `./certs` (TLS 証明書)

## テスト
- コンテナ構造テスト（CI と同じ）:
  - `docker build -t comfyui-docker:test .`
  - `docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(pwd):/workdir" \
      -w /workdir \
      gcr.io/gcp-runtimes/container-structure-test:latest \
      test --image comfyui-docker:test --config test/container-structure-test.yaml`

## 変更時のガイド
- `Dockerfile` を更新したら以下を合わせて更新する:
  - `README.md` / `README_jp.md` の説明
  - `test/container-structure-test.yaml` のバージョン検証
- `compose.yml.example` を更新した場合は `compose.yml` との差分が最小になるよう反映する。
- TLS 周りの挙動を変えた場合は README の手順と `certs/` の例を確認する。

## 注意
- TLS はコンテナ内に `TLS_KEYFILE` と `TLS_CERTFILE` が両方存在する場合のみ有効化。
- データ永続化は `./data/*` と `./certs` のボリュームマウントで行う。
